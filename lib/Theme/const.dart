import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF23A949);
const Color kSecondaryColor = Color(0xFF71F562);
const Color kTextBlackColor = Color(0xFF313131);
const Color kTextWhiteColor = Color(0xFFFFFFFF);
const Color kContainerColor = Color(0xFF777777);
const Color kOtherColor = Color(0xFFF4F6F7);
const Color kTextLightColor = Color(0xFFC5BEBE);
const Color kErrorBorderColor = Color(0xFFE74C3C);

//default Value
const kDefaultPadding = 20.0;

const sizeBox = SizedBox(
  height: kDefaultPadding,
);
const kWidthSizeBox = SizedBox(
  width: kDefaultPadding,
);

const kHalfSizeBox = SizedBox(
  height: kDefaultPadding / 2,
);
const kHalfWidthSizeBox = SizedBox(
  width: kDefaultPadding / 2,
);

//validation for mobile
const String mobilePattern = r'(^(?:[+0]9)?[0-9]{18,12}$)';

//validation for email - value not done yet
const String emailPattern =r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';