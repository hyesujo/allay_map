import 'package:alleymap_app/screen/alleymapscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AlleyExplortionScreen extends StatefulWidget {

  @override
  _AlleyExplortionScreenState createState() => _AlleyExplortionScreenState();
}

class _AlleyExplortionScreenState extends State<AlleyExplortionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          leading: IconButton(
            icon: Transform.scale(
              scale: 0.6,
              child: SvgPicture.asset(
                'assets/icons/menu.svg',
              ),
            ),
            onPressed: () => _scaffoldKey.currentState.openDrawer(),
          ),
          elevation: 0.0,
          actions: [
            IconButton
              (icon: Transform.scale(
              scale: 0.8,
                child: SvgPicture.asset(
                'assets/icons/location1.svg'
            ),
              ),
                onPressed: (){
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) =>
                    AlleyMapScreen()
                    ));
                }),
          ],
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text('골목탐방',
            style: GoogleFonts.nanumGothic(
              color: Color(0xff707070),
            ),
          ),
        ),
      ),
      drawer: new Drawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children:[
              Padding(
                padding: const EdgeInsets.only(top: 30,
                    left: 15),
                child: Container(
                  width: 320,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 3,
                            offset: Offset(0,1)
                        ),
                      ]
                  ),
                  child: TextField(
                    onChanged: (value) {
                      print(value);
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        left: 15,
                        bottom: 10
                      ),
                      border: InputBorder.none,
                      hintText: '장소를 검색하세요',  //검색시에 즐찾 가게를 찾을 수 있게
                      hintStyle: GoogleFonts.nanumGothic(
                        color: Colors.grey
                      )
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30,
                    left: 15),
                child: IconButton(
                    icon: Icon(Icons.search,
                    size: 30,),
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
            child: Text('지금 장소를 추가하세요',
              style: GoogleFonts.nanumGothic(
                  fontSize: 14,
                color: Colors.grey[600]
              ),
            ),
          ),
          Expanded(
              child: InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AlleyMapScreen()));
                },
                child: Container(
                  margin: EdgeInsets.only(left: 30),
                  width: 350,
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
