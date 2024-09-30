import 'package:chattychin/models/studentsmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentDetailsScreen extends StatefulWidget {
  final Student student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  late Map<String, String> attendanceRecords;

  @override
  void initState() {
    super.initState();
    attendanceRecords = Map.from(
        widget.student.attendance); // Initialize with the existing attendance
  }

  // Function to determine grade based on attendance count
  String determineGrade(int attendanceCount) {
    if (attendanceCount >= 26) {
      return 'A';
    } else if (attendanceCount >= 20) {
      return 'B';
    } else if (attendanceCount >= 10) {
      return 'C';
    } else if (attendanceCount >= 5) {
      return 'D';
    } else {
      return 'F';
    }
  }

  // Update the grade in Firestore
  Future<void> updateGradeInFirestore(int attendanceCount) async {
    try {
      String grade = determineGrade(attendanceCount);
      DocumentReference studentDoc = FirebaseFirestore.instance
          .collection('students')
          .doc(widget.student.uid);

      await studentDoc.update({
        'grades': grade,
      });
      print('Grade updated to: $grade');
    } catch (e) {
      print('Error updating grade in Firestore: $e');
    }
  }

  Future<void> addAttendance(String date, String time) async {
    try {
      DocumentReference studentDoc = FirebaseFirestore.instance
          .collection('students')
          .doc(widget.student.uid);

      await studentDoc.set({
        'attendance': {
          date: time,
        }
      }, SetOptions(merge: true));

      // Update local attendance records
      setState(() {
        attendanceRecords[date] = time; // Add to local records
      });

      // Update the grade in Firestore
      await updateGradeInFirestore(attendanceRecords.length);
    } catch (e) {
      print('Error adding attendance: $e');
    }
  }

  Future<void> deleteAttendance(String date) async {
    try {
      DocumentReference studentDoc = FirebaseFirestore.instance
          .collection('students')
          .doc(widget.student.uid);

      await studentDoc.update({
        'attendance.$date': FieldValue.delete(),
      });

      // Update local attendance records
      setState(() {
        attendanceRecords.remove(date); // Remove from local records
      });
      // Update the grade in Firestore
      await updateGradeInFirestore(attendanceRecords.length);
    } catch (e) {
      print('Error deleting attendance: $e');
    }
  }

  Future<void> editAttendance(
      String oldDate, String newDate, String newTime) async {
    try {
      DocumentReference studentDoc = FirebaseFirestore.instance
          .collection('students')
          .doc(widget.student.uid);

      // Remove the old attendance record
      await studentDoc.update({
        'attendance.$oldDate': FieldValue.delete(),
      });

      // Add the updated attendance record
      await studentDoc.set({
        'attendance': {
          newDate: newTime,
        }
      }, SetOptions(merge: true));

      // Update local attendance records
      setState(() {
        attendanceRecords.remove(oldDate); // Remove old date
        attendanceRecords[newDate] = newTime; // Add new date
      });

      // Update the grade in Firestore
      await updateGradeInFirestore(attendanceRecords.length);
    } catch (e) {
      print('Error editing attendance: $e');
    }
  }

  void _showAddAttendanceDialog(BuildContext context) {
    String date = '';
    String time = '';
    TextEditingController dateController = TextEditingController();
    TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Attendance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration:
                    const InputDecoration(labelText: 'Enter Date (YYYY-MM-DD)'),
                onChanged: (value) {
                  date = value;
                },
              ),
              TextField(
                controller: timeController,
                decoration:
                    const InputDecoration(labelText: 'Enter Time (HH:MM AM/PM)'),
                onChanged: (value) {
                  time = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (date.isNotEmpty && time.isNotEmpty) {
                  addAttendance(date, time);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please enter both date and time'),
                  ));
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showEditAttendanceDialog(
      BuildContext context, String oldDate, String oldTime) {
    String newDate = oldDate;
    String newTime = oldTime;
    TextEditingController dateController = TextEditingController(text: oldDate);
    TextEditingController timeController = TextEditingController(text: oldTime);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Attendance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration:
                    const InputDecoration(labelText: 'Enter New Date (YYYY-MM-DD)'),
                onChanged: (value) {
                  newDate = value;
                },
              ),
              TextField(
                controller: timeController,
                decoration:
                    const InputDecoration(labelText: 'Enter New Time (HH:MM AM/PM)'),
                onChanged: (value) {
                  newTime = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (newDate.isNotEmpty && newTime.isNotEmpty) {
                  editAttendance(oldDate, newDate, newTime);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please enter both date and time'),
                  ));
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Attendance'),
          content:
              Text('Are you sure you want to delete attendance for $date?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                deleteAttendance(date);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Student Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: widget.student.profilePic != null
                          ? NetworkImage(widget.student.profilePic)
                          : const AssetImage('assets/images/placeholder.jpeg')
                              as ImageProvider<Object>,
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          widget.student.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.email,
                                color: Colors.deepPurpleAccent),
                            const SizedBox(width: 8),
                            Text(
                              widget.student.email,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                        Text(
                          'Attendance: ${attendanceRecords.length}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                        Text(
                          'Absents: ${widget.student.absent}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                        Text(
                          'Leaves: ${widget.student.leaves}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                        Text(
                          'Grade: ${determineGrade(attendanceRecords.length)}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                        const Text(
                          'Attendance Records',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(
                color: Colors.blueGrey.shade300,
                height: 1,
                thickness: 1,
                indent: 0,
              ),
            ),
            // Attendance Records List
            Expanded(
              child: ListView(
                children: attendanceRecords.entries.map((entry) {
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        entry.value,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditAttendanceDialog(
                                  context, entry.key, entry.value);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmationDialog(context, entry.key);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: FloatingActionButton(
          onPressed: () {
            _showAddAttendanceDialog(context);
          },
          backgroundColor: Colors.deepPurpleAccent,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
