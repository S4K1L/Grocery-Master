import 'package:flutter/material.dart';
import '../../Theme/const.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback? onPress;
  final String title;

  const ButtonWidget({
    super.key,
    required this.onPress,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width/1.3,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.green,
      ),
      child: TextButton(
        onPressed: onPress,
        child: Text(title,style: TextStyle(color: kTextWhiteColor),),
      ),
    );
  }
}