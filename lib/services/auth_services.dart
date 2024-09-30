import 'package:chattychin/models/adminsmodel.dart';
import 'package:chattychin/models/studentsmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Sign Up Function
  Future<String?> signUp(
      String email, String password, String name, String userType) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = result.user;

      if (user != null) {
        // Store user data in firestore
        if (userType == 'student') {
          Student student = Student(
            uid: user.uid,
            name: name,
            email: email,
            userType: userType,
            absent: '',
            grades: '',
            leaves: '',
            present: '',
            profilePic: '',
            remainingleaves: '',
            totalclasses: '',
            attendance: {},
            leaveRequests: [],
          );

          await _firestore
              .collection('students')
              .doc(user.uid)
              .set(student.toMap());
        } else {
          Admin admin = Admin(
              name: name,
              email: email,
              userType: userType,
              uid: user.uid,
              managedStudents: [],
              actionLogs: []);
          await _firestore
              .collection('admins')
              .doc(user.uid)
              .set(admin.toMap());
        }
        return 'Success';
      }
    } catch (e) {
      return 'students ${e.toString()}'; //return error message if any
    }
    return null;
  }

  //Sign In Function
  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        DocumentSnapshot userData;
        userData = await _firestore.collection('students').doc(user.uid).get();
        if (userData.exists) {
          return 'students';
        } else {
          //if not a student then check for admin
          userData = await _firestore.collection('admins').doc(user.uid).get();
          if (userData.exists) {
            return 'admins';
          } else {
            return 'Error: Type not found';
          }
        }
      }
    } catch (e) {
      return 'students ${e.toString()}';
    }
    return null;
  }
}
