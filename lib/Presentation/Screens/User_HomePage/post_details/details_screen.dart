import 'package:flutter/material.dart';
import '../manu_model.dart';
import 'components/carousel_images.dart';
import 'components/custom_app_bar.dart';
import 'components/house_details.dart';


class DetailsScreen extends StatefulWidget {
  final MenuModel menu;

  const DetailsScreen({Key? key, required this.menu}) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              CarouselImages(widget.menu.moreImagesUrl),
              CustomAppBar(),
            ],
          ),
          //Categories(),
          Expanded(child: HouseDetails(widget.menu)),
        ],
      ),
    );
  }
}
