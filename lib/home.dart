import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        elevation: 4,
        title: const Text(
          'Health_care',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header Image and Title
                /* Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/homeimage.webp', // Update this with your image path
                        height: 100,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Avis de non-responsabilité concernant la santé",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.pinkAccent,
                        ),
                      ),
                    ],
                  ),
                ),*/
                const SizedBox(height: 30),
                // Information Cards
                _buildInfoCard(
                  title: "Pas un dispositif médical",
                  description:
                      "Cette application propose des informations générales sur la condition physique et la santé et ne remplace pas un avis médical professionnel.",
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: "À titre informatif",
                  description:
                      "Consultez votre médecin ou professionnel de la santé avant de commencer tout nouveau programme d'exercice ou de modifier votre régime alimentaire.",
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: "Limite des fonctionnalités",
                  description:
                      "Veuillez noter que cette application ne mesure pas la tension artérielle, la glycémie, mais peut vous aider à créer un journal de données.",
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pinkAccent),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
