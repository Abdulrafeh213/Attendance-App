import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var filteredAttendance = <DocumentSnapshot>[].obs;
  RxList<String> students = <String>[].obs;
  RxString selectedStudent = ''.obs;
  var isLoading = false.obs;
  var userName = ''.obs;
  final Map<String, bool> attendanceStatus = {};
  var selectedStudents = <Map<String, dynamic>>[].obs;
  var selectedDate = ''.obs;
  var attendance = <Map<String, dynamic>>[].obs;
  var userEmail = ''.obs;
  var totalClasses = 0.obs;
  var attendedClasses = 0.obs;
  var absentClasses = 0.obs;
  var attendanceDates = <String>[].obs;
  var studentId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserName();
    fetchUserData();
    fetchAttendanceDates();
  }
  void fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userEmail.value = user.email ?? '';

      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData = querySnapshot.docs.first.data();
          userName.value = userData['name'] ?? '';
          studentId.value = userData['studentId'] ?? '';

          // Fetch attendance data after getting studentId
          fetchAttendanceDates();
        } else {
          Get.snackbar("No user data found for email: ", "${user.email}");
        }
      } catch (e) {
        Get.snackbar("Error fetching user data: ", e.toString());
      }
    }
  }

  void fetchAttendanceDates() {
    try {
      FirebaseFirestore.instance
          .collection('attendance')
          .where('studentId', isEqualTo: studentId.value)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
        List<Map<String, dynamic>> attendanceData =
        snapshot.docs.map((doc) => doc.data()).toList();

        // Update attendance list
        attendance.value = attendanceData;

        // Calculate class statistics
        calculateClassStatistics();
      });
    } catch (e) {
      print('Error fetching attendance data: $e');
    }
  }

  void calculateClassStatistics() {
    // Calculate total classes
    totalClasses.value = attendance.length;

    // Calculate attended classes
    attendedClasses.value =
        attendance.where((record) => record['status'] == 'present').length;

    // Calculate absent classes
    absentClasses.value = totalClasses.value - attendedClasses.value;
  }

  List<String> getAttendanceForDate(DateTime date) {
    return attendance
        .where((record) => record['date'] == date.toIso8601String().split('T')[0])
        .map((record) => record['status'] as String)
        .toList();
  }
  // void fetchUserData() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     userEmail.value = user.email ?? '';
  //
  //     try {
  //       QuerySnapshot<Map<String, dynamic>> querySnapshot =
  //           await FirebaseFirestore.instance
  //               .collection('users')
  //               .where('email', isEqualTo: user.email)
  //               .limit(1)
  //               .get();
  //
  //       if (querySnapshot.docs.isNotEmpty) {
  //         var userData = querySnapshot.docs.first.data();
  //         userName.value = userData['name'] ?? '';
  //         studentId.value = userData['studentId'] ?? '';
  //       } else {
  //         Get.snackbar("No user data found for email: ", "${user.email}");
  //       }
  //     } catch (e) {
  //       Get.snackbar("Error fetching user data: ", e.toString());
  //     }
  //   }
  // }
  //
  // void fetchAttendanceDates() {
  //   try {
  //     FirebaseFirestore.instance
  //         .collection('attendance')
  //         .where('studentId', isEqualTo: studentId.value)
  //         .snapshots()
  //         .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
  //       List<Map<String, dynamic>> attendanceData =
  //           snapshot.docs.map((doc) => doc.data()).toList();
  //
  //       // Update attendance list
  //       attendance.value = attendanceData;
  //     });
  //   } catch (e) {
  //     Get.snackbar("Error fetching attendance data: ", e.toString());
  //   }
  // }
  //
  // void calculateClassStatistics(String selectedDate) {
  //   // Filter attendance data for the selected date
  //   List<Map<String, dynamic>> attendanceDataForDate = attendance
  //       .where((attendance) => attendance['date'] == selectedDate)
  //       .toList();
  //
  //   // Calculate total classes
  //   totalClasses.value = attendanceDataForDate.length;
  //
  //   // Calculate attended classes
  //   attendedClasses.value = attendanceDataForDate
  //       .where((attendance) => attendance['status'] == 'present')
  //       .length;
  //
  //   // Calculate absent classes
  //   absentClasses.value = totalClasses.value - attendedClasses.value;
  // }

  Stream<QuerySnapshot> getAttendance() {
    return _firestore.collection('attendance').snapshots();
  }

  void markAttendance(String studentId, String date) async {
    await _firestore.collection('attendance').add({
      'studentId': studentId,
      'date': date,
    });
  }

  void filterByDate(String date) async {
    isLoading.value = true;
    var result = await _firestore
        .collection('attendance')
        .where('date', isEqualTo: date)
        .get();
    filteredAttendance.value = result.docs;
    isLoading.value = false;
  }

  // List<String> getAttendanceForDate(DateTime date) {
  //   List<String> attendance = [];
  //   int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
  //   for (int i = 0; i < daysInMonth; i++) {
  //     attendance.add(_generateRandomAttendanceStatus());
  //   }
  //
  //   return attendance;
  // }

  String _generateRandomAttendanceStatus() {
    List<bool> shuffledValues = [true, false]..shuffle();
    return shuffledValues.first ? 'present' : '';
  }

  Future<void> fetchUserName() async {
    try {
      String? email = auth.currentUser?.email;

      if (email != null) {
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          String name = querySnapshot.docs.first['name'];
          userName.value = name;
        }
      }
    } catch (e) {
      Get.snackbar("Error fetching user name: ", e.toString());
    }
  }

  void fetchAttendance(String date) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('attendance')
              .where('date', isEqualTo: date)
              .get();

      attendance.value = querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      Get.snackbar("Error fetching attendance data: ", e.toString());
    }
  }

  Future<String?> getStudentId(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      return userSnapshot.data()?['studentId'];
    } catch (e) {
      Get.snackbar("Error fetching studentId: ", e.toString());
      return null;
    }
  }

  void addSelectedStudent(
      String userId, String studentName, String status) async {
    String? studentId = await getStudentId(userId);
    if (studentId != null) {
      selectedStudents.add({
        'studentId': studentId,
        'studentName': studentName,
        'status': status,
      });
    } else {
      Get.snackbar("StudentId not found for user with ID: ", userId);
    }
  }

  void removeSelectedStudent(String studentId) {
    selectedStudents
        .removeWhere((student) => student['studentId'] == studentId);
  }

  Future<void> submitAttendance() async {
    if (selectedStudents.isNotEmpty && selectedDate.isNotEmpty) {
      for (var student in selectedStudents) {
        String studentId = student['studentId'];
        String studentName = student['studentName'];
        String status = student['status'];

        try {
          QuerySnapshot<Map<String, dynamic>> querySnapshot =
              await FirebaseFirestore.instance
                  .collection('attendance')
                  .where('studentId', isEqualTo: studentId)
                  .where('date', isEqualTo: selectedDate.value)
                  .get();

          if (querySnapshot.docs.isNotEmpty) {
            // Update existing attendance record
            for (var doc in querySnapshot.docs) {
              await FirebaseFirestore.instance
                  .collection('attendance')
                  .doc(doc.id)
                  .update({'status': status});
            }
          } else {
            // Add new attendance record
            await FirebaseFirestore.instance.collection('attendance').add({
              'studentId': studentId,
              'studentName': studentName,
              'date': selectedDate.value,
              'status': status,
            });
          }
        } catch (e) {
          Get.snackbar("Error updating/adding attendance data: ", e.toString());
        }
      }
      Get.snackbar("Success", "Attendance submitted for selected students");
    } else {
      Get.snackbar("Error", "Please select students and date");
    }
  }
}
