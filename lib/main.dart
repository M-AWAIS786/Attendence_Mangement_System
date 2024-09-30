import 'package:chattychin/screens/admins_screens/admins_home.dart';
import 'package:chattychin/screens/authen_screens/login_screen.dart';
import 'package:chattychin/screens/users_screens/students_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trackify',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          primary: Colors.white,
          onPrimary: Colors.white,
          brightness: Brightness.light,
          surfaceTint: Colors.white,
          background: Colors.white,
        ),
        cardTheme: const CardTheme(
          color: Colors.white,
          shadowColor: Colors.grey,
          elevation: 8,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUser(); // Start the user check
  }

  Future<void> _checkUser() async {
    await Future.delayed(const Duration(seconds: 3)); // Delay for 2 seconds

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String role = userDoc['userType'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Studenthome()),
          );
          return;
        }

        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();

        if (adminDoc.exists) {
          String adminRole = adminDoc['userType'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminsHome()),
          );
          return;
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } catch (e) {
      print('Error navigating to next screen: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/logo_splash.png'), // Your splash icon here
      ),
    );
  }
}
