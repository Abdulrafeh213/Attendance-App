import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class AttendanceView extends GetView<HomeController> {
  final TextEditingController dateController = TextEditingController();

  AttendanceView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Select Date',
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
                      controller.selectedDate.value = dateController.text;
                      controller.fetchAttendance(controller.selectedDate.value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              final attendance = controller.attendance;
              if (attendance.isNotEmpty) {
                return Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Student ID')),
                        DataColumn(label: Text('Student Name')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: List<DataRow>.generate(
                        attendance.length,
                        (index) {
                          final item = attendance[index];
                          return DataRow(
                            cells: [
                              DataCell(Text(item['studentId'] ?? '')),
                              DataCell(Text(item['studentName'] ?? '')),
                              DataCell(Text(item['status'] ?? '')),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              } else {
                return const Text('No attendance data available');
              }
            }),
          ],
        ),
      ),
    );
  }
}
