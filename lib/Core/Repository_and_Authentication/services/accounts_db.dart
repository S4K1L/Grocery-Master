import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/custom_user.dart';

class AccountsDB {
  // Object to get instance of Accounts table
  CollectionReference accountReference =
  FirebaseFirestore.instance.collection("users");
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // UID used to reference the auth user
  CustomUser? user;

  AccountsDB({this.user});

  // Function to update in database
  Future<void> updateAccounts(
      String fullName,
      String type,
      String reg,
      String id,
      String fName,
      String mName,
      String dob,
      String phone,
      String pass,
      String post,
      String degree,
      String dept,
      String join,
      String semester,
      ) async {
    return await accountReference.doc(user!.uid).set({
      'uid': user!.uid,
      'fullName': fullName,
      'type': type,
      'email': user!.email,
      "reg": reg,
      "id": id,
      "fName": fName,
      "mName": mName,
      "dob": dob,
      "phone": phone,
      "pass": pass,
      "post": post,
      "degree": degree,
      "dept": dept,
      "join": join,
      "semester": semester,
    });
  }

  // Function to make list of accounts from DB
  Future<List?> createAccountDataList() async {
    var listOfAccount = [];

    await accountReference.get().then((ss) {
      if (ss != null) {
        listOfAccount = ss.docs.toList();
      } else {
        print("got no accounts");
        return [];
      }
    });

    return listOfAccount;
  }

  Future<List<DocumentSnapshot>?> getCourseStudents(String courseId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('students')
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error getting course students: $e');
      return null;
    }
  }

  Future<List<DocumentSnapshot>?> getFacultyCourses(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('courses')
          .where('createdBy', isEqualTo: userId)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error getting faculty courses: $e');
      return null;
    }
  }

  // Function to reset user password
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (error) {
      print('Error resetting password: $error');
      throw error;
    }
  }

  Future<List<DocumentSnapshot>?> getStudentsByCourse(String courseId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('students')
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error getting students by course: $e');
      return null;
    }
  }

  Future<List<DocumentSnapshot>?> getAttendanceByStudentAndCourse(
      String courseId, String studentId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error getting attendance by student and course: $e');
      return null;
    }
  }

  Future<List<DocumentSnapshot>?> getStudentCourses(String studentId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('student_courses')
          .where('studentId', isEqualTo: studentId)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching student courses: $e');
      return null;
    }
  }

}
