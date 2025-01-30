import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../authentication/controllers/authentication_controller.dart';
import '../controllers/home_controller.dart';
import 'attendance_view.dart';

class AdminView extends GetView<HomeController> {
  AdminView({super.key});
  final HomeController attendanceController = Get.put(HomeController());
  final TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Admin",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              AuthenticationController.instance.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Select Date',
                border: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          pickedDate.toString().substring(0, 10);
                      attendanceController.selectedDate.value =
                          dateController.text;
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> documents = snapshot.data!.docs;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(documents.length, (index) {
                    var studentData =
                        documents[index].data() as Map<String, dynamic>?;
                    var studentName = studentData?['name'] ?? 'Unknown';
                    var studentId = documents[index].id;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Text('${index + 1}.'),
                          const SizedBox(width: 10),
                          Text(studentName),
                          const Spacer(),
                          Checkbox(
                            value: attendanceController.selectedStudents.any(
                                (student) =>
                                    student['studentId'] == studentId &&
                                    student['status'] == 'present'),
                            onChanged: (value) {
                              if (value != null && value) {
                                attendanceController.addSelectedStudent(
                                    studentId, studentName, 'present');
                              } else {
                                attendanceController
                                    .removeSelectedStudent(studentId);
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                          const Text('Present'),
                          const SizedBox(width: 10),
                          Checkbox(
                            value: attendanceController.selectedStudents.any(
                                (student) =>
                                    student['studentId'] == studentId &&
                                    student['status'] == 'absent'),
                            onChanged: (value) {
                              if (value != null && value) {
                                attendanceController.addSelectedStudent(
                                    studentId, studentName, 'absent');
                              } else {
                                attendanceController
                                    .removeSelectedStudent(studentId);
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                          const Text('Absent'),
                        ],
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.44,
                  child: ElevatedButton(
                    onPressed: () {
                      attendanceController.submitAttendance();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue, // Text color
                    ),
                    child: const Text("Submit Attendance"),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.44,
                  child: ElevatedButton(
                    onPressed: () {
                      showAttendance();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue, // Text color
                    ),
                    child: const Text("Show Attendance"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showAttendance() {
    Get.put(HomeController());
    Get.to(() => AttendanceView());
  }
}
