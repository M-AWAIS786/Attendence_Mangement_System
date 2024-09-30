import 'dart:io';
import 'package:chattychin/models/studentsmodel.dart';
import 'package:chattychin/services/student_attendence_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  File? _image;
  Student? _currentStudent;
  final AttendenceService _attendenceService = AttendenceService();

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
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

  Future<void> getGalleryImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        print('No image picked');
      }
    } catch (e) {
      // Handle error
      print('Error picking image: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null && _currentStudent != null) {
      try {
        await _attendenceService.uploadStudentImage(_image!, _currentStudent!);
        await _fetchStudentData(); // Refresh data after upload

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error uploading image. Please try again.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors
                .red, // Optional: customize the snackbar's background color
          ),
        );
      }
    } else {
      const SnackBar(
        content: Text('No image or student Picture Selected.'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors
            .orange, // Optional: customize the snackbar's background color
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfileHeader(size),
          const SizedBox(height: 30),
          _buildInfoCard(
              Icons.person, _currentStudent?.name ?? 'Name not available'),
          const SizedBox(height: 10),
          _buildInfoCard(
              Icons.email, _currentStudent?.email ?? 'Email not available'),
          const SizedBox(height: 10),
          _buildInfoCard(
              Icons.badge, _currentStudent?.userType ?? 'Role not available'),
          const SizedBox(height: 10),
          _buildUploadButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * 0.3,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(231, 66, 64, 222),
            Color.fromARGB(231, 119, 117, 238),
          ],
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Center(
        child: Stack(
          children: [
            CircleAvatar(
              maxRadius: 80,
              backgroundImage: _image != null
                  ? FileImage(_image!)
                  : (_currentStudent?.profilePic != null &&
                          _currentStudent!.profilePic.isNotEmpty &&
                          _currentStudent!.profilePic.startsWith('http'))
                      ? NetworkImage(_currentStudent!.profilePic)
                      : const AssetImage('assets/images/placeholder.jpeg')
                          as ImageProvider<
                              Object>, // Specify type here// Placeholder image
              backgroundColor: Colors.grey[200],
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: InkWell(
                onTap: getGalleryImage,
                borderRadius: BorderRadius.circular(10),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color.fromARGB(231, 66, 64, 222),
                  child: Icon(Icons.edit, size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Icon(icon, color: const Color.fromARGB(231, 66, 64, 222)),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _uploadImage,
          icon: const Icon(
            Icons.upload,
            color: Colors.white,
          ),
          label: const Text(
            'Upload Image',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: const Color(0xFF4244DE), // Primary Button Color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
