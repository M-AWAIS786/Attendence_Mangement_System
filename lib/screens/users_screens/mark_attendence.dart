import 'package:chattychin/services/student_attendence_services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  bool attendanceMarked = false;
  String message = "";
  double percentage = 0.0;
  Timer? timer;

  final AttendenceService _attendanceService =
      AttendenceService(); // Instantiate AttendanceService

  @override
  void initState() {
    super.initState();
    _checkAttendanceStatus();
  }

  // Check if attendance is already marked for today
  void _checkAttendanceStatus() async {
    bool alreadyMarked = await _attendanceService.checkAttendence();
    if (alreadyMarked) {
      setState(() {
        attendanceMarked = true;
        message = "Attendance already marked for today!";
      });
    }
  }

  // Simulating the long press percentage increment
  void _startAttendanceProgress() {
    timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        percentage += 2; // Increase the percentage
        if (percentage >= 100) {
          percentage = 100;
          attendanceMarked = true;
          timer.cancel();
          _markAttendance(); // Mark attendance after progress reaches 100%
        }
      });
    });
  }

  void _stopAttendanceProgress() {
    if (timer != null) {
      timer!.cancel();
    }
    setState(() {
      percentage = 0; // Reset if not completed
    });
  }

  // Function to mark attendance after reaching 100%
// Function to mark attendance after reaching 100%
  void _markAttendance() async {
    try {
      // Check attendance again to avoid marking twice
      bool alreadyMarked = await _attendanceService.checkAttendence();
      if (!alreadyMarked) {
        String formattedTime = await _attendanceService.markAttendence();

        // After attendance is marked successfully, update the state
        setState(() {
          attendanceMarked =
              true; // Mark attendance only after successful write to Firestore
          message = "Attendance marked successfully at $formattedTime!";
        });
      } else {
        // Attendance already marked, update message accordingly
        setState(() {
          message = "Attendance already marked for today!";
        });
      }
    } catch (e) {
      setState(() {
        message = "Error marking attendance: $e"; // Show error if marking fails
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card for showing information
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Attendance',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          attendanceMarked
                              ? const SizedBox.shrink()
                              : Text(
                                  'Place your finger on the scanner to mark attendance.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          const SizedBox(height: 12),
                          Text(
                            "Status: ${attendanceMarked ? "Marked" : "Not Marked"}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.access_time, // You can replace this icon as needed
                      color: Colors.blue,
                      size: 50,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Divider(thickness: 2, color: Colors.grey[300]),

            // Expanded to center the button vertically
            attendanceMarked
                ? const SizedBox.shrink()
                : Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Fingerprint scanner image button
                          GestureDetector(
                            onLongPress: _startAttendanceProgress,
                            onLongPressUp: _stopAttendanceProgress,
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 224, 227, 233),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                    "assets/images/fingerprint.png",
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Show percentage while long-pressing
                          Text(
                            percentage > 0
                                ? "Progress: ${percentage.toInt()}%"
                                : "Long press to mark attendance",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),

                          // Message after attendance is marked
                          if (message.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                message,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
