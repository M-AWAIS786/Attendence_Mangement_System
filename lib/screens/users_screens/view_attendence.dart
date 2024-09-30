import 'package:chattychin/models/studentsmodel.dart';
import 'package:chattychin/services/student_attendence_services.dart';
import 'package:flutter/material.dart';

class ViewAttendance extends StatefulWidget {
  const ViewAttendance({super.key});

  @override
  State<ViewAttendance> createState() => _ViewAttendanceState();
}

class _ViewAttendanceState extends State<ViewAttendance> {
  final AttendenceService attendenceService = AttendenceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Student?>(
        future: attendenceService.viewAttendance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error: Something went wrong'),
            );
          } else if (snapshot.data?.attendance == null &&
              snapshot.data!.attendance.isEmpty) {
            return const Center(
              child: Text(
                'No data found',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          Student student = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(10.0), // Add padding to the list
            child: ListView.builder(
              itemCount: student.attendance.length,
              itemBuilder: (context, index) {
                String date = student.attendance.keys.elementAt(index);
                String time = student.attendance[date]!;

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today,
                        color: Color.fromARGB(231, 45, 42, 236)),
                    title: Text(
                      'Date: $date',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Time: $time',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    trailing: const Icon(Icons.access_time, color: Colors.grey),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
