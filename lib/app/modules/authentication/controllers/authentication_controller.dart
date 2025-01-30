import 'package:attendanceapp/app/modules/home/views/admin_view.dart';
import 'package:attendanceapp/app/modules/home/views/home_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../views/authentication_view.dart';

class AuthenticationController extends GetxController {
  static AuthenticationController instance = Get.find();
  late Rx<User?> _user;

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());
    ever(_user, _initialScreen);
  }

  _initialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => AuthenticationView());
    } else {
      Get.offAll(() => HomeView());
    }
  }

  Future<void> register(
      String email, String password, String name, String phone, String studentId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(studentId).get();

      if (userSnapshot.exists) {
        Get.snackbar("Registration Error", "User already registered");
        return;
      }
UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('users').doc(studentId).set({
        'email': email,
        'role': 'Student',
        'name': name,
        'phone': phone,
        'studentId': studentId,
      });
    } catch (e) {
      Get.snackbar("Registration Error", e.toString());
    }
  }

  void login(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

       String userEmail = userCredential.user!.email!;
      if (userEmail == 'admin@gmail.com') {
        Get.offAll(AdminView());
      } else {
        Get.offAll(HomeView());
      }
    } catch (e) {
      Get.snackbar("Login Error", e.toString());
    }
  }

  void logout() async {
    await auth.signOut();
  }
}

//   void login(String email, String password) async {
//     try {
//       await _auth.signInWithEmailAndPassword(email: email, password: password);
//       Get.offAll(HomeView());
//     } catch (e) {
//       Get.snackbar("Error", e.toString());
//     }
//   }
//
//   void logout() async {
//     await _auth.signOut();
//     Get.offAll(AuthenticationView());
//   }
// }
