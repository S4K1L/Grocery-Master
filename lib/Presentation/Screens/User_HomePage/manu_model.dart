class MenuModel {
  String imageUrl = 'https://firebasestorage.googleapis.com/v0/b/bari-bodol-47f1f.appspot.com/o/user_house_images%2F1710161784753_0.jpg?alt=media&token=19b33ce7-880d-4a46-bc9c-bd578da69c74';
  String name;
  int price;
  bool isFav;
  List<String> moreImagesUrl;
  String docId;

  MenuModel({
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.moreImagesUrl,
    required this.docId,
    required this.isFav,
  });
}
