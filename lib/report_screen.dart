/*import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  File? _generatedReport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Aperçu du Rapport',
          style: TextStyle(
            color: Colors.teal,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFA7FFEB), Color(0xFF1DE9B6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.teal),
                                )
                              : _generatedReport == null
                                  ? _buildButton(
                                      "Générer le Rapport",
                                      _generateReport,
                                    ).animate().slideY(
                                      begin: 50,
                                      duration: 600.ms,
                                      delay: 600.ms)
                                  : Column(
                                      children: [
                                        _buildButton(
                                          "Voir le Rapport",
                                          _viewReport,
                                        ).animate().slideY(
                                            begin: 50,
                                            duration: 600.ms,
                                            delay: 600.ms),
                                        const SizedBox(height: 20),
                                        _buildButton(
                                          "Télécharger le Rapport",
                                          _downloadReport,
                                        ).animate().slideY(
                                            begin: 50,
                                            duration: 600.ms,
                                            delay: 900.ms),
                                      ],
                                    ),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 10,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = "Utilisateur non connecté.";
          _isLoading = false;
        });
        return;
      }

      final healthData = await _getHealthData(user.uid);
      final nutritionData = await _getNutritionData(user.uid);
      final activityData = await _getActivityData(user.uid);
      final recommendationsData = await _getRecommendationsData(user.uid);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Rapport de Suivi de Santé",
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text("Données de Santé:",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text(healthData),
              pw.SizedBox(height: 20),
              pw.Text("Données de Nutrition:",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text(nutritionData),
              pw.SizedBox(height: 20),
              pw.Text("Données d'Activité:",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text(activityData),
              pw.SizedBox(height: 20),
              pw.Text("Recommandations:",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text(recommendationsData),
            ],
          ),
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/rapport_suivi.pdf");
      await file.writeAsBytes(await pdf.save());

      setState(() {
        _generatedReport = file;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rapport généré avec succès")),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de la génération du rapport: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _viewReport() async {
    if (_generatedReport != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFView(
            filePath: _generatedReport!.path,
          ),
        ),
      );
    }
  }

  Future<void> _downloadReport() async {
    if (_generatedReport == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final newPath = "${directory.path}/rapport_suivi_telecharge.pdf";
      await _generatedReport!.copy(newPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rapport téléchargé avec succès: $newPath")),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors du téléchargement du rapport: $e";
      });
    }
  }

  Future<String> _getHealthData(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('health_data')
          .get();
      if (snapshot.docs.isEmpty) return "Aucune donnée de santé disponible.";

      final data = snapshot.docs.first.data();
      return "Poids: ${data['weight']} kg\nTaille: ${data['height']} cm\nObjectif de poids: ${data['goal_weight']} kg";
    } catch (e) {
      return "Erreur lors de la récupération des données de santé.";
    }
  }

  Future<String> _getNutritionData(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('nutrition')
          .get();
      if (snapshot.docs.isEmpty) {
        return "Aucune donnée de nutrition disponible.";
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return "Repas: ${data['meal']}\nCalories: ${data['calories']} kcal\nProtéines: ${data['proteins']} g\nGlucides: ${data['carbs']} g\nLipides: ${data['fat']} g\n\n";
      }).join("\n");
    } catch (e) {
      return "Erreur lors de la récupération des données de nutrition.";
    }
  }

  Future<String> _getActivityData(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('activity_data')
          .get();
      if (snapshot.docs.isEmpty) return "Aucune donnée d'activité disponible.";

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return "Activité: ${data['activity_type']}\nDurée: ${data['duration']} minutes\nCalories brûlées: ${data['calories_burned']}\nDistance: ${data['distance']} km\nIntensité: ${data['intensity']}\n\n";
      }).join("\n");
    } catch (e) {
      return "Erreur lors de la récupération des données d'activité.";
    }
  }

  Future<String> _getRecommendationsData(String uid) async {
    try {
      // Placeholder for recommendations data
      return "Restez actif et mangez équilibré pour une meilleure santé.";
    } catch (e) {
      return "Erreur lors de la récupération des recommandations.";
    }
  }
}
*/