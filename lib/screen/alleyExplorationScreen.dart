import 'package:alleymap_app/config.dart';
import 'package:alleymap_app/model/user.dart';
import 'package:alleymap_app/screen/alleymapscreen.dart';
import 'package:alleymap_app/widget/CustomAppbar.dart';
import 'package:alleymap_app/widget/ReviewDrawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alleymap_app/widget/TextBox.dart';

class AlleyExplortionScreen extends StatefulWidget {
  final User user;

  AlleyExplortionScreen({
    this.user,
});

  @override
  _AlleyExplortionScreenState createState() => _AlleyExplortionScreenState();
}

class _AlleyExplortionScreenState extends State<AlleyExplortionScreen> {


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      backgroundColor: backColor,
      key: _scaffoldKey,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CustomAppbar(
            title: '골목탐방',
            scaffoldKey: _scaffoldKey,
            icon: 'assets/icons/menu.svg',
            press:  () => _scaffoldKey.currentState.openDrawer(),
            icon2:  "assets/icons/location1.svg",
            press2:  () =>
              Navigator.of(context).push(
               MaterialPageRoute(builder: (context) =>
              AlleyMapScreen())
    ),
          ),
      ),
      drawer: ReviewDrawer(w: w),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children:[
              TextBox(),
              Padding(
                padding: const EdgeInsets.only(top: 30,
                    left: 15),
                child: IconButton(
                    icon: Icon(
                      Icons.search,
                    size: 30
                    ),
                    onPressed: (){
                    }
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(
              top: 25,
              left: 20
            ),
            child: Text('가보고 싶은 장소',
            style: GoogleFonts.nanumGothic(
              fontSize: 18
            ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                top: 13,
                left: 20
            ),
            child: Text(
              '지금 장소를 추가하세요',
              style: GoogleFonts.nanumGothic(
                  fontSize: 14,
                color: Colors.grey[600]
              ),
            ),
          ),
          Expanded(
              child: InkWell(
                onTap: () =>
                  Navigator.of(context).push(
                      MaterialPageRoute(
                      builder: (context) => AlleyMapScreen())
    ),
                child: Container(
                  margin: EdgeInsets.only(left: 25),
                  width: w,
                  height: 350,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/exeploer.png'
                      ), // 장소를 추가하면 그림이 없어지게
                    )
                  ),
                ),
              ),
          ),
        ],
      ),
    );
  }
}

