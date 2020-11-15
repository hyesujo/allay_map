import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ReviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black45,
          ),
        ),
      ),
      // body: CarouselSlider(
      //   items: [],
      // ),
    );
  }
}
