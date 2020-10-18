import 'package:alleymap_app/model/user.dart';
import 'package:alleymap_app/screen/reviewWriteScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewDrawer extends StatelessWidget {

  final double w;

  const ReviewDrawer({
    @required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SafeArea(
            child: Container(
              padding: EdgeInsets.only(
                  left: w / 1.5
              ),
              child: IconButton(
                icon: Icon(Icons.close
                ),
                onPressed: ()=>
                    Navigator.of(context).pop(),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(
                    top: 25,
                    left: 20
                ),
                child: ClipOval(
                  child: Image.asset(
                    user.image,
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Container(
                    padding: EdgeInsets.only(
                        top: 20,
                        left: 20
                    ),
                    child: Text(
                      user.name,
                      style: GoogleFonts.nanumGothic(
                          fontSize: 21,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: 5,
                        left: 20
                    ),
                    child: Text(
                      user.content,
                      style: GoogleFonts.nanumGothic(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 24),
            child: ListTile(
              title: InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ReviewWritePageScreen()));
                },
                child: Text(
                  '리뷰쓰기',
                  style: GoogleFonts.nanumGothic(
                      fontSize: 18,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            title: InkWell(
              onTap: (){},
              child: Text(
                '리뷰보기',
                style: GoogleFonts.nanumGothic(
                    fontSize: 18,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

