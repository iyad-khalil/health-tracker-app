# 🩺 Application de Suivi de Santé

## Description
L'application de suivi de santé est une solution complète pour aider les utilisateurs à surveiller et à améliorer leur santé physique. Grâce à des outils interactifs, des graphiques personnalisables et des conseils adaptés, cette application accompagne les utilisateurs dans leur parcours de santé en leur permettant de fixer des objectifs et de suivre leurs progrès.

## Fonctionnalités
### Gestion des Comptes
- **Inscription** : Enregistrez-vous avec une adresse e-mail et un mot de passe.
- **Connexion** : Accédez à votre compte pour suivre vos données.
- **Gestion des données utilisateur** : Mise à jour des informations personnelles.

### Suivi de la Santé
- **Suivi des Mesures** :
  - Enregistrez votre poids, taille, et autres mesures corporelles.
  - Fixez des objectifs de perte ou de gain de poids.
  - Calculer votre Indice De Masse Corporelle.
  - Obtenez un plan de la semaine coté nutrition et activité physique pour arriver a un poids normal.
- **Suivi de l'Activité Physique** :
  - Ajoutez des activités comme marche, course, natation, etc.
  - Enregistrez la durée et les calories brûlées.
  - Visualisez tous vos activités.
- **Suivi Nutritionnel** :
  - Enregistrez vos repas et suivez vos apports caloriques.
  - Analysez les macronutriments (protéines, glucides, lipides).
  - Visualisez tous vos repas.

### Analyse et Visualisation
- **Tableau de Bord** :
  - Affichez vos progrès dans des graphiques interactifs.
  - Visualisez vos données sur des périodes personnalisables : jour, semaine, mois.
- **Rapports Personnalisés** :
  - Téléchargez des rapports PDF détaillés pour vos consultations médicales.

### Notifications et Conseils
- **Rappels Quotidiens** :
  - Notifications pour enregistrer vos données.
  - Suggestions pour respecter vos objectifs de santé.
- **Conseils Personnalisés** :
  - Recommandations basées sur vos données pour améliorer votre bien-être.

## Technologies Utilisées
### Frontend
- **Flutter** :
  - Développement mobile multiplateforme (iOS et Android).
  - Widgets interactifs et performants.
  
### Backend
- **Firebase** :
  - **Authentication** : Gestion des utilisateurs.
  - **Cloud Firestore** : Base de données en temps réel.
  - **Firebase Storage** : Stockage des fichiers (PDF).
  - **Cloud Messaging** : Notifications push pour rappels.
  - **Firebase Analytics** : Suivi des comportements utilisateur.

### Autres
- **Dart** : Langage principal pour Flutter.
- **Chart.js** : Graphiques personnalisés dans Flutter.

## Prérequis
Avant de commencer, assurez-vous d'avoir installé :
- [Flutter](https://flutter.dev/docs/get-started/install) (version recommandée : 3.x)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Android Studio ou VS Code (avec extensions Flutter/Dart)

## Installation
1. **Clonez le projet** :
   ```bash
   git clone https://github.com/iir-projets/projet-multiplateforme-e2425g1_5.git
   cd suivi-sante
   flutter pub get
   Configurer votre propre firebase console
   flutter run
