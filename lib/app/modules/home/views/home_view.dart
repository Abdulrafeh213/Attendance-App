import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../authentication/controllers/authentication_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final HomeController homeController = Get.put(HomeController());

  HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            homeController.userName.value.isEmpty
                ? "Student"
                : "Welcome, ${homeController.userName.value}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () {
                final selectedDate = homeController.selectedDate.value;
                homeController.calculateClassStatistics();

                return Column(
                  children: [
                    Text('Total Classes: ${homeController.totalClasses.value}'),
                    Text(
                        'Attended Classes: ${homeController.attendedClasses.value}'),
                    Text(
                        'Absent Classes: ${homeController.absentClasses.value}'),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
            TableCalendar(
              firstDay: DateTime.utc(2022, 1, 1),
              lastDay: DateTime.utc(2032, 12, 31),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekendStyle: TextStyle(color: Colors.red),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(color: Colors.red),
                markerDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
              eventLoader: (date) => homeController.getAttendanceForDate(date),
              onDaySelected: (selectedDate, _) {
                homeController.selectedDate.value = selectedDate.toString();
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox();

                  bool isPresent = events.contains('present');
                  bool isAbsent = events.contains('absent');

                  return Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isPresent
                            ? Colors.green.withOpacity(0.5)
                            : isAbsent
                                ? Colors.red.withOpacity(0.5)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Expanded(
            //   child: Obx(
            //         () => ListView.builder(
            //       itemCount: homeController.attendance.length,
            //       itemBuilder: (context, index) {
            //         var record = homeController.attendance[index];
            //         return ListTile(
            //           title: Text('Date: ${record['date']}'),
            //           subtitle: Text('Status: ${record['status']}'),
            //           tileColor: record['status'] == 'present'
            //               ? Colors.green.withOpacity(0.3)
            //               : Colors.red.withOpacity(0.3),
            //         );
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:table_calendar/table_calendar.dart';
// import '../../authentication/controllers/authentication_controller.dart';
// import '../controllers/home_controller.dart';
//
// class HomeView extends GetView<HomeController> {
//   final HomeController homeController = Get.put(HomeController());
//
//   HomeView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Obx(
//           () => Text(
//             homeController.userName.value.isEmpty
//                 ? "Student"
//                 : "Welcome, ${homeController.userName.value}",
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         backgroundColor: Colors.blue,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.white),
//             onPressed: () {
//               AuthenticationController.instance.logout();
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Obx(
//                 () {
//                   final selectedDate = homeController.selectedDate.value;
//                   homeController.calculateClassStatistics();
//
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                           'Total Classes: ${homeController.totalClasses.value}'),
//                       Text(
//                           'Attended Classes: ${homeController.attendedClasses.value}'),
//                       Text(
//                           'Absent Classes: ${homeController.absentClasses.value}'),
//                       const SizedBox(height: 20),
//                     ],
//                   );
//                 },
//               ),
//               TableCalendar(
//                 firstDay: DateTime.utc(2022, 1, 1),
//                 lastDay: DateTime.utc(2032, 12, 31),
//                 focusedDay: DateTime.now(),
//                 calendarFormat: CalendarFormat.month,
//                 headerStyle: const HeaderStyle(
//                   formatButtonVisible: false,
//                 ),
//                 daysOfWeekStyle: const DaysOfWeekStyle(
//                   weekendStyle: TextStyle(color: Colors.red),
//                 ),
//                 calendarStyle: CalendarStyle(
//                   todayDecoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.5),
//                     shape: BoxShape.circle,
//                   ),
//                   weekendTextStyle: const TextStyle(color: Colors.red),
//                 ),
//                 eventLoader: (date) =>
//                     homeController.getAttendanceForDate(date),
//                 onDaySelected: (selectedDate, _) {
//                   homeController.selectedDate.value = selectedDate.toString();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
