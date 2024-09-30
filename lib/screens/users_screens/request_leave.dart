import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestLeave extends StatefulWidget {
  const RequestLeave({super.key});

  @override
  State<RequestLeave> createState() => _RequestLeaveState();
}

class _RequestLeaveState extends State<RequestLeave> {
  DateTime? startDate;
  final TextEditingController leaveDaysController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  Future<void> submitLeaveRequest() async {
    // Validate that a start date and number of leave days are provided
    if (startDate == null || leaveDaysController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form')),
      );
      return;
    }

    final leaveDays = int.tryParse(leaveDaysController.text);
    if (leaveDays == null || leaveDays < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of days')),
      );
      return;
    }

    final endDate = startDate?.add(Duration(days: leaveDays - 1));
    final reason = reasonController.text;

    final leaveRequest = {
      'startDate': DateFormat('yyyy-MM-dd').format(startDate!),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate!),
      'reason': reason.isEmpty ? "No reason provided" : reason,
      'status': 'pending',
    };

    FirebaseAuth user = FirebaseAuth.instance;
    User? currentuser = user.currentUser;

    if (currentuser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(currentuser.uid)
            .update({
          'leaveRequests': FieldValue.arrayUnion([leaveRequest])
        });
        setState(() {
          startDate = null;
        });
        leaveDaysController.clear();
        reasonController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave request submitted')),
        );
      } catch (e) {
        // On failure, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit leave request: $e')),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> getLeaveRequests() async {
    FirebaseAuth user = FirebaseAuth.instance;
    User? currentuser = user.currentUser;

    final studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(currentuser!.uid)
        .get();

    final LeaveRequestData = studentDoc.data();
    return List<Map<String, dynamic>>.from(
        LeaveRequestData?['leaveRequests'] ?? []);
  }

  @override
  void dispose() {
    leaveDaysController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Date picker for start date
                ListTile(
                  contentPadding: const EdgeInsets.only(top: 8),
                  title: Text(
                    startDate == null
                        ? 'Choose start date'
                        : DateFormat('dd/MM/yyyy').format(startDate!),
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(
                    Icons.calendar_today,
                    color: Color.fromARGB(231, 45, 42, 236),
                  ),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2025),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate;
                      });
                    }
                  },
                ),

                // TextField for number of leave days
                TextField(
                  controller: leaveDaysController,
                  decoration: InputDecoration(
                    hintText: 'Number of Days',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // TextField for reason
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    hintText: 'Reason (Optional)',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: submitLeaveRequest,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Submit Request',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF4244DE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder(
                future: getLeaveRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }

                  final leaveRequests = snapshot.data!;

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: leaveRequests.length,
                      itemBuilder: (context, index) {
                        final leave = leaveRequests[index];
                        return Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5,
                                    offset: Offset(0, 3))
                              ],
                              borderRadius: BorderRadius.circular(20)),
                          child: ListTile(
                            title: Text(
                                'From: ${leave['startDate']} \nTo: ${leave['endDate']}'),
                            subtitle: Text(
                                maxLines: 5, softWrap: true, leave['reason']),
                            trailing: Text(
                                style: TextStyle(
                                    color: leave['status'] == 'pending'
                                        ? Colors.red
                                        : Colors.green),
                                leave['status'].toString().toUpperCase()),
                          ),
                        );
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
