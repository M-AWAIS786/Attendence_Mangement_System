import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'leave_details_screen.dart'; // Import your second screen

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  // Fetch the students leave requests
  Future<List<Map<String, dynamic>>> fetchAllStudents() async {
    final studentCollection = FirebaseFirestore.instance.collection('students');
    final querySnapshot = await studentCollection.get();

    // Filter students to only include those with leave requests that have a pending status
    return querySnapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .where((student) {
      final leaveRequests = student['leaveRequests'] as List<dynamic>?;

      // Check if there are leave requests and at least one is pending
      return leaveRequests != null &&
          leaveRequests.isNotEmpty &&
          leaveRequests.any((leave) => leave['status'] == 'pending');
    }).toList();
  }

  // Show the student leave requests (Name and Reason only)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAllStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error: Something went wrong'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No leave requests found'));
          }

          // Extract the list of students with leave requests
          final students = snapshot.data!;

          // Display students with their leave reason
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final leaveRequests = student['leaveRequests'] as List<dynamic>?;

              // Find the first leave request's reason (if available)
              final reason = leaveRequests != null && leaveRequests.isNotEmpty
                  ? leaveRequests[0]['reason'] ?? 'No reason'
                  : 'No leave requests';

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: ListTile(
                  title: Text(student['name'] ?? 'No Name'),
                  subtitle: Text('Reason: $reason'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to the detailed leave request screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LeaveDetailsScreen(student: student),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
