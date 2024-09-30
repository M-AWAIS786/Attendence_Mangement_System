class Admin {
  final String uid;
  final String name;
  final String email;
  final String userType;

  // Additional fields for admin-specific information
  final List<String> managedStudents; // List of student UIDs that admin manages
  final List<String> actionLogs; // Logs of admin actions

  Admin({
    required this.uid,
    required this.name,
    required this.email,
    required this.userType,
    this.managedStudents = const [],
    this.actionLogs = const [],
  });

  // Convert Admin object to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'userType': userType,
      'managedStudents': managedStudents,
      'actionLogs': actionLogs,
    };
  }

  // Create Admin object from Firestore data
  factory Admin.fromMap(Map<String, dynamic> data, String uid) {
    return Admin(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      userType: data['userType'] ?? 'admin',
      managedStudents: List<String>.from(data['managedStudents'] ?? []),
      actionLogs: List<String>.from(data['actionLogs'] ?? []),
    );
  }
}
