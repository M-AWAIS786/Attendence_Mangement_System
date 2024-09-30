// import 'package:chattychin/models/studentsmodel.dart';
// import 'package:chattychin/screens/admins_screens/admins_home.dart';
// import 'package:chattychin/screens/authen_screens/login_screen.dart';
// import 'package:chattychin/screens/users_screens/students_home.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore to access user roles

// class SplashScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     _navigateToNextScreen(context);
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Container(),
//     );
//   }

//   void _navigateToNextScreen(BuildContext context) async {
//     // Simulating a loading period
//     await Future.delayed(Duration(seconds: 3));

//     try {
//       // Check if user is logged in
//       User? user = FirebaseAuth.instance.currentUser;

//       if (user != null) {
//         // Fetch user role from Firestore
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('students')
//             .doc(user.uid)
//             .get();

//         if (userDoc.exists) {
//           String role = userDoc[
//               'UserType']; // Assuming the user document has a 'UserType' field

//           if (role == 'students') {
//             // Navigate to StudentHomeScreen
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const Studenthome()),
//             );
//           } else {
//             // Fetch user role from Firestore for admins
//             DocumentSnapshot roleDoc = await FirebaseFirestore.instance
//                 .collection('admins')
//                 .doc(user.uid)
//                 .get();

//             if (roleDoc.exists) {
//               String adminRole = roleDoc[
//                   'UserType']; // Assuming admin document also has a 'UserType' field
//               if (adminRole == 'admin') {
//                 // Navigate to AdminsHome
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AdminsHome()),
//                 );
//               }
//             }
//           }
//         }
//       } else {
//         // If user is not logged in, navigate to LoginScreen
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => Login()),
//         );
//       }
//     } catch (e) {
//       // Handle any errors
//       print('Error occurred: $e');
//       // Optionally, navigate to an error screen or show a dialog
//     }
//   }
// }

