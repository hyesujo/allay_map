import 'package:alleymap_app/config.dart';
import 'package:alleymap_app/widget/CustomAppbar.dart';
import 'package:flutter/material.dart';

class ReviewWritePageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppbar(
          title: "리뷰쓰기",
          icon: 'assets/icons/left-arrow-key.svg',
          press: () {
            Navigator.of(context).pop();
          },
          icon2: "assets/icons/home.svg",
          press2: (){},
        ),
      ),
    );
  }
}
