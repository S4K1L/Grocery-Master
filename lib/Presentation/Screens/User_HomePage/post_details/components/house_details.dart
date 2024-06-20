import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocerymaster/Theme/const.dart';
import '../../../../../Theme/styles.dart';
import '../../manu_model.dart';

class HouseDetails extends StatefulWidget {
  final MenuModel menu;
  const HouseDetails(this.menu, {super.key});

  @override
  _HouseDetailsState createState() => _HouseDetailsState();
}

class _HouseDetailsState extends State<HouseDetails> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;
  double _averageRating = 0;
  int _totalRatings = 0;

  @override
  void initState() {
    super.initState();
    _fetchRatings();
  }

  Future<void> _fetchRatings() async {
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('menu')
        .doc(widget.menu.docId)
        .collection('ratings')
        .get();

    if (ratingsSnapshot.docs.isNotEmpty) {
      double totalRating = 0;
      for (var doc in ratingsSnapshot.docs) {
        totalRating += doc['rating'];
      }
      setState(() {
        _totalRatings = ratingsSnapshot.docs.length;
        _averageRating = totalRating / _totalRatings;
      });
    }
  }

  Future<void> _submitRating() async {
    await FirebaseFirestore.instance
        .collection('menu')
        .doc(widget.menu.docId)
        .collection('ratings')
        .add({
      'rating': _rating,
      'comment': _commentController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _fetchRatings();
    _commentController.clear();
    setState(() {
      _rating = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
              const Text(
                "Price",
                style: TextStyle(fontSize: 16,color: Colors.green,),
              ),
              Row(
                children: [
                  Text(
                    'RM. ${widget.menu.price}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Column(
                    children: [
                      Text(
                        'Rating',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_totalRatings > 0)
                        Text(
                          '($_totalRatings ratings)',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ],
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
              color: Colors.green,
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
            widget.menu.details,
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: kTextBlackColor.withOpacity(0.4),
              height: 2.0,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: appPadding, top: appPadding),
          child: Text(
            'Comments',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('menu')
              .doc(widget.menu.docId)
              .collection('ratings')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(appPadding),
                child: Text('No comments yet.'),
              );
            }
            return ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: snapshot.data!.docs.map((doc) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: appPadding,
                    vertical: appPadding / 2,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${doc['comment']} - ',
                        style: TextStyle(
                          color: kTextBlackColor.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${doc['rating'].toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.only(left: appPadding),
          child: Text(
            'Rate this item',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: appPadding),
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: _rating,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  label: _rating.toString(),
                  onChanged: (value) {
                    setState(() {
                      _rating = value;
                    });
                  },
                ),
              ),
              Text(
                _rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: appPadding),
          child: TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Leave a comment',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ),
        SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: appPadding),
          child: ElevatedButton(
            onPressed: _submitRating,
            child: const Text('Submit',style: TextStyle(
              color: kTextWhiteColor
            ),),
          ),
        ),
      ],
    );
  }
}
