import 'package:flutter/material.dart';
import 'package:grocerymaster/Theme/const.dart';
import '../../../../../Theme/styles.dart';
import '../../manu_model.dart';

class HouseDetails extends StatefulWidget {
  final MenuModel Menu;
  const HouseDetails(this.Menu, {super.key});

  @override
  _HouseDetailsState createState() => _HouseDetailsState();
}

class _HouseDetailsState extends State<HouseDetails> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: appPadding,
              left: appPadding,
              right: appPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Price",style: TextStyle(fontSize: 16),),
                Text(
                  'RM. ${widget.Menu.price}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: appPadding, bottom: appPadding),
            child: Text(
              'Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: appPadding,
              right: appPadding,
              bottom: appPadding * 4,
            ),
            child: Text(
              widget.Menu.details,
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: kTextBlackColor.withOpacity(0.4),
                height: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
