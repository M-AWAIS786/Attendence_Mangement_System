import 'dart:io';

import 'package:chattychin/models/studentsmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:intl/intl.dart';

class AttendenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth user = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Check if attendance is already marked for today
  Future<bool> checkAttendence() async {
    DocumentSnapshot studentDoc = await _firestore
        .collection('students')
        .doc(user.currentUser!.uid)
        .get();

    if (studentDoc.exists) {
      Map<String, dynamic> data = studentDoc.data() as Map<String, dynamic>;

      Map<String, String> attendance =
          Map<String, String>.from(data['attendance'] ?? {});

      return attendance.containsKey(DateTime.now()
          .toIso8601String()
          .split("T")[0]); // Check if today's date exists
    }

    return false;
  }

  // Mark attendance
  Future<String> markAttendence() async {
    String currentDate = DateTime.now().toIso8601String().split("T")[0];
    String formattedTime =
        DateFormat.jm().format(DateTime.now()); // Format time as needed

    await _firestore.collection('students').doc(user.currentUser!.uid).update({
      'attendance.$currentDate':
          formattedTime, // Store the attendance with the current date
    });

    return formattedTime; // Return the formatted time
  }

  // View Attendance
  Future<Student?> viewAttendance() async {
    User? currentuser = user.currentUser;

    if (currentuser != null) {
      DocumentSnapshot studentDoc =
          await _firestore.collection('students').doc(currentuser.uid).get();

      if (studentDoc.exists) {
        Map<String, dynamic> data = studentDoc.data() as Map<String, dynamic>;
        // log("  debugging krta hu na" + data.toString());
        return Student.fromMap(data, currentuser.uid);
      }
    }

    return null;
  }

  //  Upload images sections
  // Upload image and store the URL in Firestore

  Future<void> uploadStudentImage(File imageFile, Student student) async {
    try {
      // Create a reference to the image in Firebase Storage
      Reference ref = _storage.ref().child(
          'user_images/${student.uid}/${DateTime.now().toIso8601String()}');
      // Upload the file
      await ref.putFile(imageFile);
      // Get the download URL
      String downloadUrl = await ref.getDownloadURL();

      // Update the student profile image URL in Firestore
      student.profilePic = downloadUrl; // Update the Student object
      await _firestore
          .collection('students')
          .doc(student.uid)
          .set(student.toMap(), SetOptions(merge: true));

      print('Image uploaded successfully. URL: $downloadUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  // fetch the profile url of the student from the firestore

  // Fetch the profile image URL from Firestore
  Future<Student?> fetchProfileStudent() async {
    User? currentuser = user.currentUser;
    try {
      DocumentSnapshot studentDoc =
          await _firestore.collection('students').doc(currentuser!.uid).get();
      if (studentDoc.exists) {
        return Student.fromMap(
            studentDoc.data() as Map<String, dynamic>, currentuser.uid);
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
    return null;
  }
}
