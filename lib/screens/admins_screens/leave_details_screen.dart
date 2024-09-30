import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaveDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const LeaveDetailsScreen({super.key, required this.student});

  @override
  State<LeaveDetailsScreen> createState() => _LeaveDetailsScreenState();
}

class _LeaveDetailsScreenState extends State<LeaveDetailsScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;

  // Update the status of the leave request (approve or reject)
  // Update the status of the leave request (approve or reject)

  Future<void> updateLeaveStatus(
      String studentId, int leaveIndex, String newStatus) async {
    final studentDoc =
        FirebaseFirestore.instance.collection('students').doc(studentId);

    try {
      // Fetch the current leave requests and leave count
      final studentSnapshot = await studentDoc.get();
      final leaveRequests = List<Map<String, dynamic>>.from(
          studentSnapshot.data()?['leaveRequests'] ?? []);
      int currentLeaves =
          int.tryParse(studentSnapshot.data()?['leaves'] ?? '0') ?? 0;

      // Update the status of the specific leave request
      leaveRequests[leaveIndex]['status'] = newStatus;

      // Increment leaves count if the leave is approved
      if (newStatus == 'approved') {
        currentLeaves += 1; // Increment by 1 for each approved leave
      }

      // Save the updated leave requests and convert leaves count back to a string before saving
      await studentDoc.update({
        'leaveRequests': leaveRequests,
        'leaves': currentLeaves.toString(), // Store as a string in Firestore
      });

      log("Leave request updated for student $studentId");

      // Refresh the UI after updating
      setState(() {});
    } catch (e) {
      log('Error updating leave request: $e');
    }
  }

  // Function to pick a date range (from or to)
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  // Function to filter leave requests by date range

  List<dynamic> _filterLeaveRequests(List<dynamic> leaveRequests) {
    if (_fromDate == null && _toDate == null) return leaveRequests;

    return leaveRequests.where((leave) {
      DateTime? startDate = leave['startDate'] != null
          ? DateTime.parse(leave['startDate'])
          : null;
      DateTime? endDate =
          leave['endDate'] != null ? DateTime.parse(leave['endDate']) : null;

      if (startDate != null && endDate != null) {
        if (_fromDate != null && startDate.isBefore(_fromDate!)) return false;
        if (_toDate != null && endDate.isAfter(_toDate!)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final leaveRequests = widget.student['leaveRequests'] as List<dynamic>?;

    final filteredLeaveRequests =
        leaveRequests != null ? _filterLeaveRequests(leaveRequests) : [];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "${widget.student['name']}'s Leave Requests",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(231, 66, 64, 222),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context, true),
                  icon: const Icon(
                    Icons.date_range,
                    color: Colors.white,
                  ),
                  label: Text(
                    _fromDate == null
                        ? 'From Date'
                        : 'From: ${_fromDate!.toLocal()}'.split(' ')[0],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(231, 66, 64, 222),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context, true),
                  icon: const Icon(
                    Icons.date_range_outlined,
                    color: Colors.white,
                  ),
                  label: Text(
                    _toDate == null
                        ? 'To Date'
                        : 'To: ${_toDate!.toLocal()}'.split(' ')[0],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(231, 66, 64, 222),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredLeaveRequests.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredLeaveRequests.length,
                    itemBuilder: (context, index) {
                      var leave = filteredLeaveRequests[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      color: Color.fromARGB(231, 45, 42, 236)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'From: ${leave['startDate'] ?? 'No date'} To: ${leave['endDate'] ?? 'No date'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color.fromARGB(231, 45, 42, 236),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Reason: ${leave['reason'] ?? 'No reason'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Status: ${leave['status'] ?? 'No status'}',
                                    style: TextStyle(
                                      color: leave['status'] == 'pending'
                                          ? Colors.orange
                                          : leave['status'] == 'approved'
                                              ? Colors.green
                                              : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (leave['status'] == 'pending')
                                        ElevatedButton(
                                          onPressed: () => updateLeaveStatus(
                                              widget.student['id'],
                                              index,
                                              'approved'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                          ),
                                          child: const Text(
                                            'Approve',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      const SizedBox(width: 10),
                                      if (leave['status'] == 'pending')
                                        ElevatedButton(
                                          onPressed: () => updateLeaveStatus(
                                              widget.student['id'],
                                              index,
                                              'rejected'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                          ),
                                          child: const Text(
                                            'Reject',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'No leave requests found for this student',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
