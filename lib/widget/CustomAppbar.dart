import 'package:alleymap_app/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppbar extends StatelessWidget {
  final String icon, icon2, title;
  final GestureTapCallback press, press2;

  CustomAppbar(
      {Key key,
      GlobalKey<ScaffoldState> scaffoldKey,
      @required this.icon,
      @required this.press,
      this.icon2,
      this.title,
      this.press2});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Transform.scale(
          scale: 0.6,
          child: SvgPicture.asset(
            icon,
            color: kcolorgrey,
          ),
        ),
        onPressed: press,
      ),
      elevation: 0.0,
      actions: [
        IconButton(
            icon: Transform.scale(
              scale: 0.6,
              child: SvgPicture.asset(
                icon2,
                color: kcolorgrey,
              ),
            ),
            onPressed: press2)
      ],
      centerTitle: true,
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: GoogleFonts.nanumGothic(
          color: kcolorgrey,
        ),
      ),
    );
  }
}
