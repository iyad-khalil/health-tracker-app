import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io' show Platform, File;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PdfSummaryScreen extends StatefulWidget {
  const PdfSummaryScreen({super.key});

  @override
  _PdfSummaryScreenState createState() => _PdfSummaryScreenState();
}

class _PdfSummaryScreenState extends State<PdfSummaryScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _healthInfo;
  Map<String, dynamic>? _nutritionInfo;
  List<Map<String, dynamic>> _activityInfo = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      if (_user == null) {
        setState(() {
          _errorMessage = "Utilisateur non connecté.";
          _isLoading = false;
        });
        return;
      }

      // Fetch health information
      final healthSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('health_data')
          .limit(1)
          .get();

      if (healthSnapshot.docs.isNotEmpty) {
        _healthInfo = healthSnapshot.docs.first.data();
      }

      // Fetch nutrition information
      final nutritionSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('nutrition')
          .get();

      if (nutritionSnapshot.docs.isNotEmpty) {
        _nutritionInfo = {
          'calories': nutritionSnapshot.docs
              .fold<int>(0, (sum, doc) => sum + (doc['calories'] ?? 0) as int),
          'proteins': nutritionSnapshot.docs
              .fold<int>(0, (sum, doc) => sum + (doc['proteins'] ?? 0) as int),
          'carbs': nutritionSnapshot.docs
              .fold<int>(0, (sum, doc) => sum + (doc['carbs'] ?? 0) as int),
          'fat': nutritionSnapshot.docs
              .fold<int>(0, (sum, doc) => sum + (doc['fat'] ?? 0) as int),
        };
      }

      // Fetch activity information
      final activitySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('activity_data')
          .orderBy('timestamp', descending: true)
          .get();

      _activityInfo = activitySnapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors du chargement des données: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePdf() async {
    try {
      final pdf = pw.Document();

      // Build the PDF content
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Rapport de Suivi de Santé',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal,
                  )),
              pw.SizedBox(height: 20),
              if (_healthInfo != null) _buildPdfHealthInfo(),
              pw.SizedBox(height: 20),
              if (_nutritionInfo != null) _buildPdfNutritionInfo(),
              pw.SizedBox(height: 20),
              if (_activityInfo.isNotEmpty) _buildPdfActivityInfo(),
            ],
          ),
        ),
      );

      if (kIsWeb) {
        final pdfBytes = await pdf.save();
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = 'rapport_suivi_sante.pdf'
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = Platform.isAndroid || Platform.isIOS
            ? await getApplicationDocumentsDirectory()
            : await getDownloadsDirectory();

        if (directory == null) {
          throw Exception("Impossible de trouver un répertoire valide");
        }

        final file = File("${directory.path}/rapport_suivi_sante.pdf");
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Rapport enregistré avec succès: ${file.path}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la génération du rapport: $e")),
      );
    }
  }

  pw.Widget _buildPdfHealthInfo() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.teal, width: 2),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      padding: pw.EdgeInsets.all(8),
      margin: pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Informations de Santé',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            ),
          ),
          pw.Divider(color: PdfColors.teal, thickness: 1),
          pw.Text("Poids: ${_healthInfo!['weight']} kg"),
          pw.Text("Taille: ${_healthInfo!['height']} cm"),
          pw.Text("Objectif de Poids: ${_healthInfo!['goal_weight']} kg"),
        ],
      ),
    );
  }

  pw.Widget _buildPdfNutritionInfo() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.orange, width: 2),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      padding: pw.EdgeInsets.all(8),
      margin: pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Informations Nutritionnelles',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange,
            ),
          ),
          pw.Divider(color: PdfColors.orange, thickness: 1),
          pw.Text("Calories Totales: ${_nutritionInfo!['calories']} kcal"),
          pw.Text("Protéines Totales: ${_nutritionInfo!['proteins']} g"),
          pw.Text("Glucides Totaux: ${_nutritionInfo!['carbs']} g"),
          pw.Text("Lipides Totaux: ${_nutritionInfo!['fat']} g"),
        ],
      ),
    );
  }

  pw.Widget _buildPdfActivityInfo() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue, width: 2),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      padding: pw.EdgeInsets.all(8),
      margin: pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Historique des Activités',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.Divider(color: PdfColors.blue, thickness: 1),
          ..._activityInfo.map((activity) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Type d'activité: ${activity['activity_type']}"),
                pw.Text("Durée: ${activity['duration']} minutes"),
                pw.Text("Calories Brûlées: ${activity['calories_burned']}"),
                pw.Text("Distance: ${activity['distance']} km"),
                pw.Text("Intensité: ${activity['intensity']}"),
                pw.SizedBox(height: 5),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFA7FFEB), Color(0xFF1DE9B6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : _errorMessage != null
                    ? Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _generatePdf,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 10,
                            ),
                            child: const Text(
                              "Télécharger le Rapport",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ).animate().slideY(
                                begin: 50,
                                duration: 600.ms,
                                delay: 300.ms,
                              ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
