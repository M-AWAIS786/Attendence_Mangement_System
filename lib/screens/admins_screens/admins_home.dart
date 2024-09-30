import 'package:chattychin/models/adminsmodel.dart';
import 'package:chattychin/screens/admins_screens/View_attendence.dart';
import 'package:chattychin/screens/admins_screens/leave_request.dart';
import 'package:chattychin/screens/authen_screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminsHome extends StatefulWidget {
  const AdminsHome({super.key});

  @override
  State<AdminsHome> createState() => _AdminsHomeState();
}

class _AdminsHomeState extends State<AdminsHome> {
  int _currentIndex = 0;
  String _appBarTitle = "View Student";
  final List<Widget> _screen = [
    const ViewAttendanceScreen(),
    const LeaveRequestScreen(),
  ];
  Admin? _currentAdmin;
  FirebaseAuth user = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchProfileAdmin();
  }

  Future<void> fetchProfileAdmin() async {
    User? currentuser = user.currentUser;
    try {
      DocumentSnapshot adminDoc =
          await _firestore.collection('admins').doc(currentuser!.uid).get();
      if (adminDoc.exists) {
        setState(() {
          _currentAdmin = Admin.fromMap(
              adminDoc.data() as Map<String, dynamic>, currentuser.uid);
        });
      }
    } catch (e) {
      print('Error fetching admin data: $e');
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
          _appBarTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(231, 66, 64, 222),
      ),
      drawer: Drawer(
        elevation: 10,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        child: ListView(
          shrinkWrap: true,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color.fromARGB(231, 66, 64, 222),
                  Color.fromARGB(231, 119, 117, 238),
                ]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          width: 2,
                          color: Colors.white,
                        ),
                        image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/images/placeholder.jpeg'),
                        )),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentAdmin?.name != null
                            ? _currentAdmin!.name.toString().toUpperCase()
                            : 'Your Name',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                      Text(
                        _currentAdmin?.email != null
                            ? _currentAdmin!.email
                            : 'Your Name',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
            ),
            _buildDrawerItem(
                index: 0, icon: Icons.check_box, title: 'View Students'),
            _buildDrawerItem(
                index: 1, icon: Icons.request_page, title: 'Leave Requests'),
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
      body: _screen[_currentIndex],
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
