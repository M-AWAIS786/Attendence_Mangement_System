import 'package:chattychin/models/studentsmodel.dart';
import 'package:chattychin/screens/admins_screens/View_attendence_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewAttendanceScreen extends StatefulWidget {
  const ViewAttendanceScreen({super.key});

  @override
  State<ViewAttendanceScreen> createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  Future<List<Student>> fetchAllStudents() async {
    try {
      final studentCollection =
          FirebaseFirestore.instance.collection('students');
      final querySnapshot = await studentCollection.get();

      // Check if documents are retrieved
      if (querySnapshot.docs.isEmpty) {
        throw Exception('No students found in Firestore');
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();

        // Log the fetched data for debugging
        print('Fetched data: $data');

        // Create a Student object from the valid data
        return Student.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching students: $e');
      throw Exception('Failed to fetch students');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Student>>(
          future: fetchAllStudents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Log the error
              print('Error in FutureBuilder: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data found'));
            }

            // Extract the list of students
            final students = snapshot.data!;

            // Display students in a ListView
            return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        student.name.isNotEmpty
                            ? student.name[0].toUpperCase()
                            : 'N', // Default letter if name is empty
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    title: Text(
                      student.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(student.email),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Navigate to detailed view
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentDetailsScreen(student: student),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
