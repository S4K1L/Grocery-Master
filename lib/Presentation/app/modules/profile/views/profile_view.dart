import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocerymaster/Presentation/app/modules/welcome/views/welcome_view.dart';
import '../../../../../Core/Firebase/Auth.dart';
import '../../../../../Core/Repository_and_Authentication/custom_buttons.dart';
import '../../../../../Core/Repository_and_Authentication/profile_image_picker.dart';
import '../../../../../Theme/const.dart';


class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthService _auth = AuthService();
  Map<String, dynamic> userData = {};

  // Function to fetch user data from Firebase
  Future<void> getUserData() async {
    try {
      // Get the current user's UID from FirebaseAuth
      String userUID = FirebaseAuth.instance.currentUser!.uid;
      // Fetch user data using the UID
      DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .get();
      // Convert the fetched data into a Map
      Map<String, dynamic> userDataMap =
      userDataSnapshot.data() as Map<String, dynamic>;

      // Update the userData map and trigger a rebuild
      setState(() {
        userData = userDataMap;
      });
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData(); // Call the function to fetch user data when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 8,
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Profile",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: kOtherColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          kHalfSizeBox,
                          ProfileImagePicker(),
                          SizedBox(height: 20),
                          ProfileDataColumn(
                            title: 'Name : ',
                            value: userData['username'] ?? '',
                          ),
                          ProfileDataColumn(
                            title: 'Phone : ',
                            value: userData['phone'] ?? '',
                          ),
                          ProfileDataColumn(
                            title: 'Email : ',
                            value: userData['email'] ?? '',
                          ),
                          ProfileDataColumn(
                            title: 'Address : ',
                            value: userData['address'] ?? '',
                          ),
                          CustomButton(onPress: (){
                            FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => WelcomeView()),
                            );
                          }, title: "SIGN OUT")
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileDataColumn extends StatelessWidget {
  const ProfileDataColumn({super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: kTextBlackColor,
                  fontSize: 15.0,
                ),
              ),
              kHalfSizeBox,
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: kTextBlackColor,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              kHalfSizeBox,
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                child: const Divider(
                  thickness: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}