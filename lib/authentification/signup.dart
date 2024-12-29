import 'package:flutter/material.dart';
import 'package:flutter_app/authentification/authentification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/mainscreen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA7FFEB), Color(0xFF1DE9B6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(),
                  const SizedBox(height: 30),
                  _buildWelcomeText(),
                  const SizedBox(height: 40),
                  _buildInputFields(),
                  const SizedBox(height: 30),
                  if (_errorMessage != null) _buildErrorMessage(),
                  const SizedBox(height: 20),
                  _buildSignUpButton(),
                  const SizedBox(height: 20),
                  _buildLoginPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_add,
        size: 60,
        color: Colors.teal,
      ),
    )
        .animate(controller: _animationController)
        .scale(duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        const Text(
          "Rejoignez-nous !",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )
            .animate(controller: _animationController)
            .fadeIn(duration: 600.ms, delay: 300.ms),
        const SizedBox(height: 10),
        const Text(
          "Commencer à suivre votre santé",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        )
            .animate(controller: _animationController)
            .fadeIn(duration: 600.ms, delay: 600.ms),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _usernameController,
          hintText: "Entrez votre nom d'utilisateur",
          labelText: "Nom d'utilisateur",
          icon: Icons.person,
        )
            .animate(controller: _animationController)
            .slideX(begin: -50, end: 0, duration: 600.ms, delay: 900.ms)
            .fadeIn(duration: 600.ms, delay: 900.ms),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _emailController,
          hintText: "Entrez votre email",
          labelText: "Email",
          icon: Icons.email,
        )
            .animate(controller: _animationController)
            .slideX(begin: 50, end: 0, duration: 600.ms, delay: 1200.ms)
            .fadeIn(duration: 600.ms, delay: 1200.ms),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _passwordController,
          hintText: "Entrez votre mot de passe",
          labelText: "Mot De Passe",
          icon: Icons.lock,
          isPassword: true,
        )
            .animate(controller: _animationController)
            .slideX(begin: -50, end: 0, duration: 600.ms, delay: 1500.ms)
            .fadeIn(duration: 600.ms, delay: 1500.ms),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: Icon(icon),
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

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red),
      ),
    ).animate(controller: _animationController).shake(duration: 300.ms);
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: 300,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 10,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              )
            : const Text(
                "Créer un compte",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    )
        .animate(controller: _animationController)
        .scale(duration: 600.ms, delay: 1800.ms);
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Vous avez déjà un compte ?",
          style: TextStyle(color: Colors.white70),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "Connectez-vous",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    )
        .animate(controller: _animationController)
        .fadeIn(duration: 600.ms, delay: 600.ms);
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _auth.registerUserWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Store additional user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': _usernameController.text,
          'email': _emailController.text,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        setState(() {
          _errorMessage = "Le mot de passe est court.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Une erreur s'est produite. Veuillez réessayer.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
