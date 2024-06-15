import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CarouselImages extends StatefulWidget {
  final List<String> imagesListUrl;

  const CarouselImages(this.imagesListUrl, {Key? key}) : super(key: key);

  @override
  _CarouselImagesState createState() => _CarouselImagesState();
}

class _CarouselImagesState extends State<CarouselImages> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: size.height * 0.30,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imagesListUrl.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: widget.imagesListUrl[index],
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      width: _currentPage == index ? 12.0 : 8.0,
      height: _currentPage == index ? 12.0 : 8.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.blue : Colors.grey,
      ),
    );
  }
}
