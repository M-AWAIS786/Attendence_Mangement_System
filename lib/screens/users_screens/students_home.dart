import 'package:chattychin/models/studentsmodel.dart';
import 'package:chattychin/screens/authen_screens/login_screen.dart';
import 'package:chattychin/screens/users_screens/dashboard.dart';
import 'package:chattychin/screens/users_screens/mark_attendence.dart';
import 'package:chattychin/screens/users_screens/profile.dart';
import 'package:chattychin/screens/users_screens/request_leave.dart';
import 'package:chattychin/screens/users_screens/view_attendence.dart';
import 'package:chattychin/services/student_attendence_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Studenthome extends StatefulWidget {
  const Studenthome({super.key});

  @override
  State<Studenthome> createState() => _StudenthomeState();
}

class _StudenthomeState extends State<Studenthome> {
  int _currentIndex = 0;
  String _appBarTitle = "Dashboard"; // Add a variable for AppBar title
  final AttendenceService _attendenceService = AttendenceService();
  Student? _currentStudent;
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
    // Initialize the screens list
    _screens.add(const Dashboard());
    _screens.add(const MarkAttendanceScreen()); // Pass uid here
    _screens.add(const RequestLeave());
    _screens.add(const ViewAttendance());
    _screens.add(const UserProfile());
  }

  Future<void> _fetchStudentData() async {
    try {
      _currentStudent = await _attendenceService.fetchProfileStudent();
      setState(() {}); // Update UI after fetching data
    } catch (e) {
      // Handle error
      print('Error fetching student data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the color of the menu icon
        ),
        title: Text(
          _appBarTitle, // Use the variable for the title
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(231, 66, 64, 222),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        elevation: 10,
        surfaceTintColor: Colors.white,
        child: ListView(
          shrinkWrap: true,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(231, 66, 64, 222),
                    Color.fromARGB(231, 119, 117, 238),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          width: 2,
                          color: Colors.white,
                        ),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _currentStudent?.profilePic != null
                              ? NetworkImage(_currentStudent!.profilePic)
                              : const AssetImage('assets/images/placeholder.jpeg')
                                  as ImageProvider<Object>,
                        )),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentStudent?.name != null ? _currentStudent!.name.toString().toUpperCase() : 'Your Name',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                      Text(
                        _currentStudent?.email != null ? _currentStudent!.email : 'Your Name',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
            ),
            _buildDrawerItem(
              index: 0,
              icon: Icons.dashboard,
              title: 'Dashboard',
            ),
            _buildDrawerItem(
              index: 1,
              icon: Icons.check_box,
              title: 'Mark Attendance',
            ),
            _buildDrawerItem(
              index: 2,
              icon: Icons.request_page,
              title: 'Request Leave',
            ),
            _buildDrawerItem(
              index: 3,
              icon: Icons.view_list,
              title: 'View Attendance',
            ),
            _buildDrawerItem(
              index: 4,
              icon: Icons.person,
              title: 'Profile',
            ),
            ListTile(
              onTap: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const Login()));
                });
              },
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
    );
  }

  Widget _buildDrawerItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    return ListTile(
      selected: _currentIndex == index,
      selectedTileColor: const Color.fromARGB(231, 66, 64, 222)
          .withOpacity(0.2), // Highlight selected tile
      leading: Icon(
        icon,
        color: _currentIndex == index
            ? const Color.fromARGB(231, 66, 64, 222)
            : Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _currentIndex == index
              ? const Color.fromARGB(231, 66, 64, 222)
              : Colors.black,
          fontWeight:
              _currentIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _currentIndex = index;
          _appBarTitle = title; // Update the appBar title
        });
        Navigator.of(context).pop(); // Close the drawer after selection
      },
    );
  }
}
