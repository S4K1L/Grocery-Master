import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../data/custom_user.dart';


class ClassesDB {

  CollectionReference classReference = FirebaseFirestore.instance.collection("courses");
  CollectionReference studentReference = FirebaseFirestore.instance.collection("addCourses");

  // uid used to reference the teacher/creator
  CustomUser? user;

  ClassesDB({this.user});


  // function to update in class in database
  Future<void> updateClasses(String className, String description, Color uiColor) async {
    return await classReference.doc(className).set({
      'className': className,
      'description': description,
      'creator': user!.uid,
      'uiColor': uiColor.value.toString(),
    });
  }

  // function to add student to class
  Future<void> updateStudentClasses(String className) async {
    return await studentReference.doc(user!.uid + "___" + className).set({
      'className' : className,
      'uid' : user!.uid
    });
  }

  // function to make list of accounts from DB
  Future<List?> createClassesDataList() async {
    return await classReference.get().then(  (ss) => ss.docs.toList()  );
  }

  // function to get list of students from DB
  Future<List?> makeStudentsAccountList() async {
    return await studentReference.get().then(  (ss) => ss.docs.toList()  );
  }



// function to retrieve courses created by the faculty
  Future<List<Map<String, dynamic>>?> getFacultyCourses() async {
    // Query the classReference collection for documents where creator is equal to the user's ID
    QuerySnapshot querySnapshot = await classReference
        .where('creator', isEqualTo: user!.uid)
        .get();

    // Convert the documents to a list of maps
    List<Map<String, dynamic>> courses = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      // Get the number of students joined for each course
      QuerySnapshot studentsSnapshot = await studentReference
          .where('className', isEqualTo: doc['className'])
          .get();
      int studentsJoined = studentsSnapshot.docs.length;

      // Add the course data along with the number of students joined to the list
      courses.add({
        ...doc.data() as Map<String, dynamic>,
        'studentsJoined': studentsJoined,
      });
    }

    return courses;
  }

  // function to retrieve courses assigned to the student
  Future<List<Map<String, dynamic>>?> getCourseStudents(String courseId) async {
    QuerySnapshot querySnapshot = await studentReference
        .where('uid', isEqualTo: user!.uid)
        .get();

    List<Map<String, dynamic>> courses = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      DocumentSnapshot courseDoc = await classReference.doc(doc['className']).get();
      if (courseDoc.exists) {
        courses.add(courseDoc.data() as Map<String, dynamic>);
      }
    }

    return courses;
  }
}