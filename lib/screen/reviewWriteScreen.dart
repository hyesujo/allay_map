import 'dart:io';

import 'package:alleymap_app/config.dart';
import 'package:alleymap_app/screen/alleyExplorationScreen.dart';
import 'package:alleymap_app/widget/CustomAppbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';

class ReviewWritePageScreen extends StatefulWidget {

  @override
  _ReviewWritePageScreenState createState() => _ReviewWritePageScreenState();
}

class _ReviewWritePageScreenState extends State<ReviewWritePageScreen> {
  double _rating;
  List<File> userImages;
  File _image;
  int userImageIndex = 0;
  GlobalKey<ScaffoldState> _sdkey = GlobalKey<ScaffoldState>();
  final ImagePicker picker = ImagePicker();
  ScrollController sController;
  bool nextIconView = false;
  TextEditingController _contentCtrl = TextEditingController();

  @override
  void initState() {
    this.userImages = []; //담아주는거 잊지말기 아니면 null이 호출됨
    this.sController = new ScrollController()
      ..addListener(() {
        setState(() {
          this.iconView();
        });
      });
    super.initState();
  }



  void iconView() {
    if(sController.offset >= sController.position.maxScrollExtent) {
      nextIconView = false;
    } else {
      nextIconView = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _sdkey,
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
          press2: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AlleyExplortionScreen()));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 35,
                    left: 30
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width *0.27,
                  height: MediaQuery.of(context).size.height *0.15,
                  child: Image(
                    image: AssetImage('assets/images/plop.jpg'),
                    fit: BoxFit.cover,
                  ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Padding(
                      padding:EdgeInsets.only(
                        top: 35,
                        left: 20,
                      ),
                      child: Text(
                        'PLOP',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding:EdgeInsets.only(
                        top: 5,
                        left: 20,
                      ),
                      child: Text(
                        '응암동 721-1',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Padding(
                      padding:EdgeInsets.only(
                        top: 25,
                        left: 20,
                      ),
                      child: Text(
                        '포토리뷰 이벤트!',
                        style: TextStyle(
                          fontSize: 15,
                          color: pointColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ]
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(
                left: 30,
                top: 30
              ),
                child: Text(
                    "별점을 눌러 만족도를 평가해 주세요!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600
                ),
                ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 25,
                top: 15
              ),
              child: RatingBar(
                  initialRating: 3.0,
                  minRating: 0.5,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  unratedColor: Colors.grey[300],
                  itemPadding: EdgeInsets.symmetric(
                    horizontal: 4.0
                  ),
                  itemBuilder: (BuildContext context, int i) =>
                  Icon(Icons.star,
                 color: pointColor,
                   ),
                  onRatingUpdate: (rating) {
                   setState(() {
                     _rating = rating;
                   });
                  }),
            ),
            Container(
              padding: EdgeInsets.only(
                  left: 30,
                  top: 10,
              ),
              child: Text(
                "별점을 선택해주세요",
                style: TextStyle(
                  color: greyColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w400
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  left: 30,
                  top: 35
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children:[
                  Text(
                    "사진을 올려주세요:)",
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 5),
                    child: Text("(선택)",
                      style: TextStyle(
                        fontSize: 17,
                        color: greyColor
                      ),
                    ),
                  ),
                ]
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  left: 30,
                  top: 10
              ),
              child: Text(
                "방문했던 장소의 추억을 올려주세요\n"
                    "관련없는 사진이나 부적합한 사진을 등록하시는 경우,\n"
                    "리뷰가 삭제될 수 있습니다.",
                style: TextStyle(
                  color: greyColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400
                ),
              ),
            ),
            InkWell(
                onTap: this.userImages.length >= 3 ?
                    () => _sdkey.currentState.showSnackBar(
                    SnackBar(content: Text("이미지는 3개까지에요!"),
                      duration: Duration(seconds: 2),
                    )
                ): () async{
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("사진을 선택해주세요:)",
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("촬영하기"),
                          onPressed: () async {
                            takePicture();
                          },
                        ),
                        FlatButton(
                          child: Text("앨범"),
                          onPressed: () async {
                            getImage();
                          },
                        ),
                      ],
                    ),
                  );
                },
              child: Container(
                padding: EdgeInsets.only(
                    left: 20,
                top: 13
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height /5.5,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child:
                          this.userImages.isEmpty ?
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 30,
                                    right: 10
                                  ),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    child: Image.asset("assets/images/plus.png"),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 10,
                                    right: 10
                                  ),
                                  child: Text(
                                    this.userImages.length >= 3 ?
                                    "이미지는 3개까지에요" :"사진업로드",
                                    style: TextStyle(
                                        color: greyColor
                                    ),
                                  ),
                                )
                              ])
                            : SizedBox(
                              height: 200,
                              child: ListView.builder(
                                padding: EdgeInsets.all(10.0),
                                scrollDirection: Axis.horizontal,
                                controller: this.sController,
                              shrinkWrap: true,
                              itemCount: this.userImages.length,
                              itemBuilder: (BuildContext context, int index){
                                  return Stack(
                                children:[
                               Container(
                                 width: MediaQuery.of(context).size.width *0.3,
                                 height: MediaQuery.of(context).size.height *0.15,
                                 child: Card(
                                   shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(15),
                                   ),
                                   clipBehavior: Clip.antiAlias,
                                   borderOnForeground: false,
                                   child: Image.file(
                                     this.userImages[index],
                                     fit: BoxFit.cover,
                                   ),
                                 ),
                               ),
                                  Positioned(
                                    top: -5,
                                      right: -1,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            this.userImages
                                                .remove(this.userImages[index]);
                                            iconCountCheck();
                                          });
                                        },
                                        child: Container(
                                          width: 30.0,
                                          height: 30.0,
                                          margin: EdgeInsets.all(5.0),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius: BorderRadius.circular(30)
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.close,
                                              size: 20.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ),
                                ]
                              );
                              }),
                            ),
                        ),
                      ]
                    ),
                  ),
              ),
            ),
            ),
            Container(
              padding: EdgeInsets.only(
                  left: 30,
                  top: 10
              ),
              child: Text(
                "리뷰를 작성해주세요.",
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w600
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  left: 30,
                  top: 20
              ),
              child: Container(
                child: TextFormField(
                  controller: _contentCtrl,
                  minLines: 1,
                  maxLines: 4,
                  validator: (value) {
                    if(value.isEmpty) {
                      return "리뷰를 입력해주세요";
                    } else
                      return null;
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      top: 10,
                      left: 10,
                      right: 5
                    ),
                    hintText: "방문하신 곳에서 있었던 일, 느꼈던 것을 편안하게 작성해 주세요.",
                  ),
                ),
                width: MediaQuery.of(context).size.width *0.82,
                height: MediaQuery.of(context).size.height /3.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: Colors.black45,
                  width: 2.0
                  )
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.only(
                left: 30
              ),
              child: FlatButton(
                  onPressed: (){},
                color: pointColor,
                child: Container(
                  width: MediaQuery.of(context).size.width *0.74,
                  height: MediaQuery.of(context).size.height /13,
                  child: Center(
                      child: Text("저장하기",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17
                        ),
                      ),
                  ),
                ),
                ),
            ),
          SizedBox(
            height: 20,
          )
          ],
        ),
      ),
    );
  }
  Future takePicture() async {
    PickedFile pickedFile =
    await picker.getImage(source: ImageSource.camera);
    this._image = File(pickedFile.path);

    setState(() {
      this.userImages.add(_image);
    });

    Navigator.of(context).pop();
}
  void getImage() async {
    PickedFile pickedFile =
    await picker.getImage(source: ImageSource.gallery);
    if(pickedFile ==null) return;

    File pathfile = File(pickedFile.path);

    setState(() {
    this.userImages.add(pathfile);
    });
    Navigator.of(context).pop();
  }

  void iconCountCheck() {
    if (userImages.length >= 2) {
      nextIconView = true;
      return;
    }
    nextIconView =false;
    return;
  }

  Widget iconViewContainer() {
    return Container(
      child: Icon(Icons.add),
    );
  }
}

