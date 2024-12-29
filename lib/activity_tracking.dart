import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ActivityTrackingScreen extends StatefulWidget {
  const ActivityTrackingScreen({super.key});

  @override
  _ActivityTrackingScreenState createState() => _ActivityTrackingScreenState();
}

class _ActivityTrackingScreenState extends State<ActivityTrackingScreen> {
  final _activityTypeController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _distanceController = TextEditingController();
  final _notesController = TextEditingController();
  String _intensity = 'Modérée';
  DateTime? _activityDate;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _activityTypeController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadLastActivity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final lastActivity = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('activity_data')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (lastActivity.docs.isNotEmpty) {
          final data = lastActivity.docs.first.data();
          setState(() {
            _activityTypeController.text = data['activity_type'] ?? '';
            _durationController.text = (data['duration'] ?? '').toString();
            _caloriesController.text =
                (data['calories_burned'] ?? '').toString();
            _distanceController.text = (data['distance'] ?? '').toString();
            _intensity = data['intensity'] ?? 'Modérée';
            _activityDate = data['activity_date'] != null
                ? (data['activity_date'] as Timestamp).toDate()
                : null;
            _notesController.text = data['notes'] ?? '';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage =
              "Erreur lors du chargement de l'activité : ${e.toString()}";
        });
      }
    }
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
                    'Suivi des Activités',
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
                        Icons.directions_run,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildTextField(
                        controller: _activityTypeController,
                        label: "Type d'activité (ex: marche, course)",
                        icon: Icons.directions_run,
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _durationController,
                        label: "Durée (minutes)",
                        icon: Icons.timer,
                      ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _caloriesController,
                        label: "Calories brûlées",
                        icon: Icons.local_fire_department,
                      ).animate().fadeIn(duration: 600.ms, delay: 900.ms),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _distanceController,
                        label: "Distance parcourue (km)",
                        icon: Icons.map,
                      ).animate().fadeIn(duration: 600.ms, delay: 1200.ms),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _intensity,
                        decoration: InputDecoration(
                          labelText: "Intensité de l'activité",
                          prefixIcon:
                              const Icon(Icons.speed, color: Colors.teal),
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
                            borderSide:
                                const BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                        items: ['Légère', 'Modérée', 'Élevée']
                            .map((label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _intensity = value!;
                          });
                        },
                      ).animate().fadeIn(duration: 600.ms, delay: 1500.ms),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.teal),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _activityDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _activityDate = pickedDate;
                                });
                              }
                            },
                            child: Text(
                              "Date de l'activité: ${_activityDate?.toLocal().toString().split(' ')[0] ?? 'Non sélectionnée'}",
                              style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 600.ms, delay: 1800.ms),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _notesController,
                        label: "Notes sur l'activité",
                        icon: Icons.note,
                        isMultiline: true,
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
                                    onPressed: _saveActivity,
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
                                    onPressed: _viewAllActivities,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 10,
                                    ),
                                    child: const Text(
                                      "Voir toutes les activités",
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

  Future<void> _saveActivity() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_activityTypeController.text.isEmpty ||
          _durationController.text.isEmpty ||
          _caloriesController.text.isEmpty ||
          _distanceController.text.isEmpty) {
        setState(() {
          _errorMessage = "Veuillez entrer toutes les informations.";
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

      final activityData = {
        'activity_type': _activityTypeController.text,
        'duration': int.tryParse(_durationController.text) ?? 0,
        'calories_burned': int.tryParse(_caloriesController.text) ?? 0,
        'distance': double.tryParse(_distanceController.text) ?? 0,
        'intensity': _intensity,
        'activity_date': _activityDate ?? FieldValue.serverTimestamp(),
        'notes': _notesController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activity_data')
          .add(activityData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Activité enregistré avec succès!",
            style: TextStyle(fontSize: 14),
          ),
        ),
      );

      _activityTypeController.clear();
      _durationController.clear();
      _caloriesController.clear();
      _distanceController.clear();
      _notesController.clear();
      setState(() {
        _intensity = 'Modérée';
        _activityDate = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Une erreur est survenue. Veuillez réessayer.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _viewAllActivities() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final activitiesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('activity_data')
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
            "Toutes les activités",
            style: TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: activitiesSnapshot.docs.map((doc) {
                final data = doc.data();
                return ListTile(
                  title: Text(
                    data['activity_type'] ?? "Activité inconnue",
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
                            title: const Text("Supprimer l'activité"),
                            content: const Text(
                                "Êtes-vous sûr de vouloir supprimer cette activité?"),
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
                            .collection('activity_data')
                            .doc(doc.id)
                            .delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Activité supprimée avec succès!"),
                          ),
                        );

                        // Remove the deleted activity from the list
                        setState(() {
                          activitiesSnapshot.docs
                              .removeWhere((d) => d.id == doc.id);
                        });
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _viewActivityDetails(data);
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

  void _viewActivityDetails(Map<String, dynamic> activityData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: Text(
            activityData['activity_type'] ?? "Détails de l'activité",
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
                "Durée: ${activityData['duration']} minutes",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Calories brûlées: ${activityData['calories_burned']}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Distance: ${activityData['distance']} km",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Intensité: ${activityData['intensity']}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Date: ${(activityData['activity_date'] as Timestamp).toDate().toLocal().toString().split(' ')[0]}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Notes: ${activityData['notes'] ?? 'Aucune'}",
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
