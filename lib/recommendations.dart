import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  double? _bmi;
  String _bmiStatus = "";
  String _recommendation = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHealthInfo();
  }

  Future<void> _fetchHealthInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot healthData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('health_data')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get()
          .then((snapshot) => snapshot.docs.first);

      double weight = healthData['weight'] ?? 0;
      double heightCm = healthData['height'] ?? 0;
      double heightM = heightCm / 100;
      if (weight > 0 && heightM > 0) {
        setState(() {
          _bmi = weight / pow(heightM, 2);
          _bmiStatus = _calculateBmiStatus(_bmi!);
          _recommendation = _generateRecommendation(_bmi!);
        });
      }
    } catch (e) {
      setState(() {
        _bmi = null;
        _bmiStatus = "Veuillez entrer vos données.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _calculateBmiStatus(double bmi) {
    if (bmi < 18.5) {
      return "Insuffisance pondérale";
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return "Poids normal";
    } else if (bmi >= 25 && bmi < 29.9) {
      return "Surpoids";
    } else {
      return "Obésité";
    }
  }

  String _generateRecommendation(double bmi) {
    const double normalBmiLower = 18.5;
    const double normalBmiUpper = 24.9;
    String recommendation = "";

    if (bmi < normalBmiLower) {
      double weightToGain =
          (normalBmiLower * pow(_getHeightInMeters(), 2)) - _getWeight();
      recommendation =
          "Votre IMC est inférieur à la normale. Vous devez prendre environ ${weightToGain.toStringAsFixed(1)} kg pour atteindre un IMC normal. Voici quelques recommandations pour y parvenir :\n\n";
      recommendation += _generateNutritionPlanForWeightGain();
    } else if (bmi > normalBmiUpper) {
      double weightToLose =
          _getWeight() - (normalBmiUpper * pow(_getHeightInMeters(), 2));
      recommendation =
          "Votre IMC est supérieur à la normale. Vous devez perdre environ ${weightToLose.toStringAsFixed(1)} kg pour atteindre un IMC normal. Voici quelques recommandations pour y parvenir :\n\n";
      recommendation += _generateNutritionAndExercisePlanForWeightLoss();
    } else {
      recommendation =
          "Votre IMC est dans la plage normale. Continuez à maintenir un mode de vie équilibré pour rester en bonne santé.";
    }

    return recommendation;
  }

  double _getHeightInMeters() {
    return 1.75; // Replace this with actual user height in meters from database
  }

  double _getWeight() {
    return 70.0; // Replace this with actual user weight from database
  }

  String _generateNutritionPlanForWeightGain() {
    return "- Mangez plus souvent : Incluez des collations saines tout au long de la journée.\n- Augmentez votre apport en protéines : Ajoutez des aliments riches en protéines à chaque repas.\n- Consommez des aliments riches en nutriments : Choisissez des aliments caloriques mais nutritifs, comme les noix, les graines, et les avocats.";
  }

  String _generateNutritionAndExercisePlanForWeightLoss() {
    return "- Réduisez les calories : Créez un déficit calorique en choisissant des portions plus petites et des aliments à faible teneur en calories.\n- Activité physique : Faites au moins 30 minutes d'exercice par jour, comme la marche rapide ou la natation.\n- Planification hebdomadaire :\n  Lundi : Cardio (30 min) et légumes verts.\n  Mardi : Yoga (20 min) et fruits riches en fibres.\n  Mercredi : Renforcement musculaire (30 min) et protéines maigres.\n  Jeudi : Cardio léger (30 min) et repas équilibré.\n  Vendredi : Marche rapide (40 min) et salade composée.\n  Samedi : Activité ludique (danse, vélo) et collation saine.\n  Dimanche : Repos actif et hydratation.";
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
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Recommandations',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade700, Colors.teal.shade300],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.health_and_safety,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_bmi != null)
                              _buildInfoCard(
                                "Votre IMC",
                                _bmi!.toStringAsFixed(1),
                                Icons.monitor_weight,
                                Colors.blue,
                              )
                                  .animate()
                                  .fadeIn(duration: 600.ms, delay: 300.ms),
                            const SizedBox(height: 16),
                            if (_bmiStatus.isNotEmpty)
                              _buildInfoCard(
                                "Statut",
                                _bmiStatus,
                                Icons.info_outline,
                                Colors.orange,
                              )
                                  .animate()
                                  .fadeIn(duration: 600.ms, delay: 600.ms),
                            const SizedBox(height: 24),
                            const Text(
                              "Recommandations :",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ).animate().fadeIn(duration: 600.ms, delay: 900.ms),
                            const SizedBox(height: 16),
                            _buildRecommendationCard(_recommendation)
                                .animate()
                                .slideY(
                                    begin: 50,
                                    duration: 600.ms,
                                    delay: 1200.ms),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(String recommendation) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: recommendation.split('\n').map((line) {
            if (line.startsWith('-')) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        line.substring(1).trim(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  line,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }
          }).toList(),
        ),
      ),
    );
  }
}
