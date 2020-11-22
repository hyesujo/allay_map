import 'package:alleymap_app/config.dart';
import 'package:alleymap_app/model/place.dart';
import 'package:alleymap_app/model/review.dart';
import 'package:alleymap_app/service/reviewService.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  PlaceNearby placeNearby;

  ReviewScreen({this.placeNearby});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  ReviewService reviewService = ReviewService();

  List<Review> reviewList = [];

  Review review = Review();

  final List<String> infophoto = [
    'assets/images/plop1.jpg',
    "assets/images/plop2.jpg",
    "assets/images/plop3.jpg"
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    readData();
  }

  void readData() async {
    List<Review> reviewList =
        await reviewService.getReview(widget.placeNearby.placeId);
    setState(() {
      if (reviewList.length > 0) {
        print("dddd-${reviewList[0]}");
        this.review = reviewList[0];
        this.reviewList = reviewList;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(
              Icons.arrow_back_ios,
              size: 25,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.favorite_border,
                size: 25,
                color: Colors.white,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.share,
                size: 25,
                color: Colors.white,
              ),
              onPressed: () {}),
        ],
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onHorizontalDragEnd: (DragEndDetails detail) {
                if (detail.velocity.pixelsPerSecond.dx > 0) {
                  _preve();
                } else if (detail.velocity.pixelsPerSecond.dx < 0) {
                  _next();
                }
              },
              child: Container(
                width: double.infinity,
                height: size.height * 0.45,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(infophoto[currentIndex]),
                      fit: BoxFit.cover),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 90,
                      margin: EdgeInsets.only(bottom: 25),
                      child: Row(
                        children: _buildIndicator(),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Row(children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      "PLOP",
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10, left: 15),
                    child: Text(
                      "응암동 721-1",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.only(top: 30, right: 25),
                child: Text.rich(
                  TextSpan(
                      text: "리뷰",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                          text: "${reviewList.length}",
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: pointColor),
                        )
                      ]),
                ),
              )
            ]),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Column(children: [
                Container(
                  padding: EdgeInsets.only(left: 25),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: pointColor,
                        size: 40,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          "${review.rating}/", //placeId랑 연동을 해서 가져오는 방법
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          "5",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600]),
                        ),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Container(
                        height: size.height * 0.12,
                        width: 1.5,
                        color: Colors.grey[400],
                      ),
                      Column(
                        children: [
                          Row(children: [
                            Container(
                              padding: EdgeInsets.only(top: 20, left: 20),
                              child: Text(
                                '5점',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 20, left: 10),
                              child: Container(
                                width: size.width * 0.13,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: pointColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 20),
                              child: Container(
                                width: size.width * 0.07,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    bottomRight: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.only(top: 20, left: 13),
                                child: Text("42")), //전체를 위젯이나 메소드로 뺄수 있는지
                          ]),
                        ],
                      ),
                    ],
                  ),
                  width: size.width * 0.85,
                  height: size.height * 0.18,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return Container(
      width: 75,
      height: 35,
      child: Center(
        child: Text(
          "${currentIndex + 1} / ${infophoto.length}",
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  List<Widget> _buildIndicator() {
    List<Widget> indicator = [];
    for (int i = 0; i < infophoto.length; i++) {
      if (currentIndex == i) {
        indicator.add(_indicator(true));
      } else {
        indicator.add(_indicator(false));
      }
      return indicator;
    }
  }

  void _preve() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      } else {
        currentIndex = 0;
      }
    });
  }

  void _next() {
    setState(() {
      if (currentIndex < infophoto.length - 1) {
        currentIndex++;
      } else {
        currentIndex = currentIndex;
      }
    });
  }
}
