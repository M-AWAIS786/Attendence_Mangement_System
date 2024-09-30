class Student {
  final String uid;
  final String name;
  final String email;
  final String userType;
  String profilePic;
  final String leaves; // You might want to change this to int if it's a count
  final String absent; // Consider changing this to int
  final String present; // Consider changing this to int
  final String grades; // Consider changing this to a more structured type
  final String totalclasses; // Consider changing this to int
  final String remainingleaves; // Consider changing this to int
  final Map<String, String> attendance;
  final List<Map<String, dynamic>> leaveRequests;

  Student({
    required this.uid,
    required this.name,
    required this.email,
    required this.userType,
    required this.profilePic,
    this.leaves = '0', // Default to '0' or use nullable type
    this.absent = '0', // Default to '0'
    this.present = '0', // Default to '0'
    this.grades = '', // Default to empty string or consider making it nullable
    this.totalclasses = '0', // Default to '0'
    this.remainingleaves = '0', // Default to '0'
    required this.attendance,
    required this.leaveRequests,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'userType': userType,
        'profilePic': profilePic,
        'leaves': leaves,
        'absent': absent,
        'present': present,
        'grades': grades,
        'totalclasses': totalclasses,
        'remainingleaves': remainingleaves,
        'attendance': attendance,
        'leaveRequests': leaveRequests,
      };

  factory Student.fromMap(Map<String, dynamic> json, String uid) {
    // Log the JSON for debugging
    print('Creating Student from JSON: $json');

    return Student(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      userType: json['userType'] ?? '',
      profilePic: json['profilePic'] ?? '',
      leaves: json['leaves'] ?? '0',
      absent: json['absent'] ?? '0',
      present: json['present'] ?? '0',
      grades: json['grades'] ?? '',
      totalclasses: json['totalclasses'] ?? '0',
      remainingleaves: json['remainingleaves'] ?? '0',
      attendance: Map<String, String>.from(json['attendance'] ?? {}),
      leaveRequests:
          List<Map<String, dynamic>>.from(json['leaveRequests'] ?? []),
    );
  }
}
