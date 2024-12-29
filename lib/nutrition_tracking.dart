import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NutritionTrackingScreen extends StatefulWidget {
  const NutritionTrackingScreen({super.key});

  @override
  _NutritionTrackingScreenState createState() =>
      _NutritionTrackingScreenState();
}

class _NutritionTrackingScreenState extends State<NutritionTrackingScreen> {
  final _mealController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _mealTimeController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mealController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _mealTimeController.dispose();
    _notesController.dispose();
    super.dispose();
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
                    'Suivi de nutritions',
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
                        Icons.restaurant,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildTextField(
                        controller: _mealController,
                        label: "Nom du repas (ex: Déjeuner, Dîner)",
                        icon: Icons.restaurant,
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _caloriesController,
                        label: "Calories (kcal)",
                        icon: Icons.local_fire_department,
                      ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _proteinController,
                        label: "Protéines (g)",
                        icon: Icons.fitness_center,
                      ).animate().fadeIn(duration: 600.ms, delay: 900.ms),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _carbsController,
                        label: "Glucides (g)",
                        icon: Icons.rice_bowl,
                      ).animate().fadeIn(duration: 600.ms, delay: 1200.ms),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _fatController,
                        label: "Lipides (g)",
                        icon: Icons.opacity,
                      ).animate().fadeIn(duration: 600.ms, delay: 1500.ms),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _mealTimeController,
                        label: "Heure du repas (ex: Petit-déjeuner)",
                        icon: Icons.access_time,
                      ).animate().fadeIn(duration: 600.ms, delay: 1800.ms),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _notesController,
                        label: "Notes sur le repas",
                        icon: Icons.notes,
                      ).animate().fadeIn(duration: 600.ms, delay: 2100.ms),
                      const SizedBox(height: 30),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 2400.ms),
                      _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.teal),
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  width: 300,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _saveMeal,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 10,
                                    ),
                                    child: const Text(
                                      "Enregistrer",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ).animate().slideY(
                                    begin: 50, duration: 600.ms, delay: 600.ms),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: 300,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _viewAllMeals,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 10,
                                    ),
                                    child: const Text(
                                      "Voir tous les repas",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ).animate().slideY(
                                    begin: 50, duration: 600.ms, delay: 600.ms),
                              ],
                            ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isMultiline = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isMultiline ? TextInputType.multiline : TextInputType.text,
      maxLines: isMultiline ? 3 : 1,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }

  Future<void> _saveMeal() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_mealController.text.isEmpty ||
          _caloriesController.text.isEmpty ||
          _proteinController.text.isEmpty ||
          _carbsController.text.isEmpty ||
          _fatController.text.isEmpty ||
          _mealTimeController.text.isEmpty) {
        setState(() {
          _errorMessage = "Veuillez remplir tous les champs.";
          _isLoading = false;
        });
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = "Utilisateur non connecté.";
          _isLoading = false;
        });
        return;
      }

      final mealData = {
        'meal': _mealController.text,
        'calories': int.tryParse(_caloriesController.text) ?? 0,
        'proteins': int.tryParse(_proteinController.text) ?? 0,
        'carbs': int.tryParse(_carbsController.text) ?? 0,
        'fat': int.tryParse(_fatController.text) ?? 0,
        'mealTime': _mealTimeController.text,
        'notes': _notesController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('nutrition')
          .add(mealData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Repas enregistré avec succès!",
            style: TextStyle(fontSize: 14),
          ),
        ),
      );

      _mealController.clear();
      _caloriesController.clear();
      _proteinController.clear();
      _carbsController.clear();
      _fatController.clear();
      _mealTimeController.clear();
      _notesController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de l'enregistrement.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _viewAllMeals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    final meals = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('nutrition')
        .orderBy('timestamp', descending: true)
        .get();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            "Liste des repas",
            style: TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: meals.docs.map((doc) {
                final data = doc.data();
                return ListTile(
                  title: Text(
                    data['meal'] ?? "Nom inconnu",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Confirm deletion before proceeding
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Supprimer le repas"),
                            content: const Text(
                                "Êtes-vous sûr de vouloir supprimer ce repas?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text(
                                  "Annuler",
                                  style: TextStyle(color: Colors.teal),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text("Supprimer"),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldDelete ?? false) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('nutrition')
                            .doc(doc.id)
                            .delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Activité supprimée avec succès!"),
                          ),
                        );

                        // Remove the deleted activity from the list
                        setState(() {
                          meals.docs.removeWhere((d) => d.id == doc.id);
                        });
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _viewMealDetails(data);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Fermer",
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _viewMealDetails(Map<String, dynamic> mealData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: Text(
            mealData['meal'] ?? "Détails du repas",
            style: const TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Calories: ${mealData['calories']} kcal",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Protéines: ${mealData['proteins']} g",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Glucides: ${mealData['carbs']} g",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Lipides: ${mealData['fat']} g",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Heure du repas: ${mealData['mealTime']}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Notes: ${mealData['notes'] ?? 'Aucune'}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Fermer",
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
