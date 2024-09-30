import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? studentData;
  int absentsCount = 0;
  late DateTime currentTime;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
    // Start the clock timer
    currentTime = DateTime.now();
    _updateTime();
  }

  void _updateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        currentTime = DateTime.now();
      });
      _updateTime(); // Call this function recursively
    });
  }

  Future<void> _fetchStudentData() async {
    if (user == null) return;

    final studentDoc =
        FirebaseFirestore.instance.collection('students').doc(user!.uid);

    try {
      final studentSnapshot = await studentDoc.get();
      setState(() {
        studentData = studentSnapshot.data();
      });
      _calculateAbsents();
    } catch (e) {
      print('Error fetching student data: $e');
    }
  }

  Future<void> _calculateAbsents() async {
    if (studentData == null) return;

    List<dynamic> leaves = studentData?['leaveRequests'] ?? [];
    Map<String, dynamic> attendance = studentData?['attendance'] ?? {};

    DateTime startDate =
        DateTime(2024, 9, 20); // Start date for attendance tracking
    DateTime currentDate = DateTime.now();
    DateTime checkDate = startDate;

    int absentsCount = 0;

    while (checkDate.isBefore(currentDate) ||
        checkDate.isAtSameMomentAs(currentDate)) {
      bool isAbsent = true;

      for (var leave in leaves) {
        DateTime leaveStartDate = DateTime.parse(leave['startDate']);
        DateTime leaveEndDate = DateTime.parse(leave['endDate']);
        if (checkDate.isAfter(leaveStartDate) &&
            checkDate.isBefore(leaveEndDate) &&
            leave['status'] == "approved") {
          isAbsent = false; // Approved leave found
          break;
        }
      }

      if (attendance
          .containsKey(checkDate.toIso8601String().split("T").first)) {
        isAbsent = false; // Attendance found for this date
      }

      if (isAbsent) {
        absentsCount++;
        print(
            "Absent on: ${checkDate.toIso8601String().split("T").first}"); // Log absent days
      }

      checkDate = DateTime(checkDate.year, checkDate.month,
          checkDate.day + 1); // Move to next day
    }

    setState(() {
      studentData?['absent'] =
          absentsCount.toString(); // Store the absents count as string
    });

    print("Total Absents Count: $absentsCount"); // Log total absents count

    await _updateAbsentCount(absentsCount);
  }

  Future<void> _updateAbsentCount(int absentsCount) async {
    if (user == null) return;

    final studentDoc =
        FirebaseFirestore.instance.collection('students').doc(user!.uid);

    try {
      await studentDoc.update({
        'absent': absentsCount.toString()
      }); // Update absent field in Firestore
      print("Firestore absent field updated to: $absentsCount");
    } catch (e) {
      print('Error updating absent count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: studentData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  // Today's Date and Real-time Clock
                  _buildDateTimeCard(),
                  const SizedBox(height: 8.0),

                  // Attendance Card
                  _buildInfoCard(
                    title: 'Attendance',
                    value: studentData?['attendance'] != null
                        ? studentData!['attendance'].length.toString()
                        : '0',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 8.0),

                  // Leaves Card
                  _buildInfoCard(
                    title: 'Leaves Approved',
                    value: studentData?['leaves'] ?? '0',
                    icon: Icons.beach_access,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 8.0),

                  // Absents Card
                  _buildInfoCard(
                    title: 'Absents',
                    value: studentData?['absent'] ?? '0',
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
    );
  }

  // Function to build the date and time card
  Widget _buildDateTimeCard() {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEEE, MMMM d, y').format(currentTime), // Full date
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              DateFormat('hh:mm:ss a').format(currentTime), // Real-time clock
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build info cards

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(
          icon,
          color: color,
          size: 40,
        ),
        title: Text(title, style: const TextStyle(fontSize: 20)),
        subtitle: Text(
          value,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}
