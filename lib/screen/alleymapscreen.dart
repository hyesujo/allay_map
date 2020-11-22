import 'dart:async';
import 'dart:convert';
import 'package:alleymap_app/config.dart';
import 'package:alleymap_app/constant.dart';
import 'package:alleymap_app/model/place.dart';
import 'package:alleymap_app/screen/reviewScreen.dart';
import 'package:alleymap_app/screen/reviewWriteScreen.dart';
import 'package:alleymap_app/service/Place_Service.dart';
import 'package:alleymap_app/service/googlemapService.dart';
import 'package:alleymap_app/widget/ReviewDrawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class AlleyMapScreen extends StatefulWidget {
  @override
  _AlleyMapScreenState createState() => _AlleyMapScreenState();
}

class _AlleyMapScreenState extends State<AlleyMapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Set<Marker> _markers = {};
  LatLng currentPos = LatLng(37.551052, 126.991568);
  MapType _googleMapType = MapType.normal;
  Completer<GoogleMapController> _mapController = Completer();
  Location location = Location();
  final TextEditingController _searchController = TextEditingController();
  double zoomLevel = 15;
  double zoomLevelMax = 20;
  double zoomLevelMin = 0;
  GlobalKey<FormBuilderState> _fbkey = GlobalKey<FormBuilderState>();
  final panelController = PanelController();

  List<PlaceNearby> placeIdList = [];

  var uuid = Uuid();
  var sessionToken;

  PlaceDetail placeDetail; //선언만 해준 상태이니 인스턴스 화를 해줘야 함
  PlaceNearby placeNearby;

  GoogleMapServices googleMapServices;

  PlaceService _placeService = PlaceService();

  List<PlaceNearby> placeNearbyList = [];

  void getCurrentPosition() async {
    LocationData pos = await location.getLocation();
    setState(() {
      currentPos = LatLng(
        pos.latitude,
        pos.longitude,
      );
    });

    placeDetail =
        PlaceDetail(lng: pos.longitude, lat: pos.latitude); //placeDetail 인스턴스화함

    // _placeService.listPlace().then((value) => print(value));
    _placeService
        .listPlacebyLocation(LatLng(pos.latitude, pos.longitude))
        .listen((List<DocumentSnapshot> docs) {
      print('place list by -${docs.length}');
      List<PlaceNearby> nearbyList =
          docs.map((doc) => PlaceNearby.fromFirebase(doc.data())).toList();
      setState(() {
        this.placeNearbyList = nearbyList;
      });
    });
    GoogleMapController mapCtrl = await _mapController.future;
    mapCtrl.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(currentPos.latitude, currentPos.longitude),
            zoom: zoomLevel),
      ),
    );
  }

  void _allayShop() {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            child: Column(
              children: [
                Material(
                  child: FormBuilder(
                    key: _fbkey,
                    child: Column(
                      children: [
                        FormBuilderDropdown(
                          attribute: "placeId",
                          hint: Text("어떤 장소를 찾으세요?"),
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(),
                          ),
                          validators: [
                            FormBuilderValidators.required(
                                errorText: '장소 선택을 해주세요')
                          ],
                          items: places.map<DropdownMenuItem<String>>((place) {
                            return DropdownMenuItem<String>(
                                value: place['id'],
                                child: Text(place['placeName']));
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                MaterialButton(
                  child: Text(
                    '확인',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: _submit,
                  color: pointColor,
                  textColor: Colors.white,
                )
              ],
            ),
          );
        });
  }

  void _searchPlaces(
      String locationName, double latitude, double longitude) async {
    _markers.clear();

    final String nearUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    String _url =
        "$nearUrl?key=$API_KEY&location=$latitude,$longitude&radius=1500&language=ko&keyword=$locationName";

    try {
      final http.Response _response = await http.get(_url);
      if (_response.statusCode == 200) {
        final data = json.decode(_response.body);
        if (data['status'] == 'OK') {
          GoogleMapController controller = await _mapController.future;
          controller.animateCamera(
              CameraUpdate.newLatLng(LatLng(latitude, longitude)));

          List<dynamic> result = data["results"]; //다이나믹 리스트 형태로 받아옴
          List<PlaceNearby> placeNear = result
              .map((data) => PlaceNearby.fromJson(data))
              .toList(); //PlaceNearby를 인스턴스화함 .
          //result를 PlaceNearby클래스로 변경해서 받아줌

          List<String> placeIdList = [];

          for (int i = 0; i < placeNear.length; i++) {
            PlaceNearby placeNearby = placeNear[i];
            placeIdList.add(placeNearby.placeId);
            print("placccee id_${placeNearby.placeId}");

            _markers.add(
              Marker(
                markerId: MarkerId(placeNearby.placeId),
                position: LatLng(
                  placeNearby.lat,
                  placeNearby.lng,
                ),
                infoWindow: InfoWindow(
                    title: placeNearby.name,
                    snippet: placeNearby.vicinity,
                    onTap: () {
                      //1.지우고 새로불러오기
                      //2 또는 기존 데이터를 가지고 필터링
                      //  print("${placeNearby.name}");
                      // googleMapServices.getPlaceDetailList(placeNearby.placeId);
                    }),
              ),
            );
            // googleMapServices.getPlaceDetailList(placeNearby.placeId);
          } //내가 준비한 데이터를 지도위에 보여주기 위해서 임
          setState(() {
            _markers;
          });

          print('place id list - $placeIdList');
          var detailDataResult =
              await getPlaceDetails(placeIdList); //함수이름 바꿀때 리네임기능쓰기
          print("detail1122 - $detailDataResult");
        }
      } else {
        print('Fail to fetch place data');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List> getPlaceDetails(List<String> placeIdList) {
    List details = [];

    for (int i = 0; i < placeIdList.length; i++) {
      print('placeId1111-${placeIdList[i]}');
      try {
        details.add(googleMapServices.getPlaceDetailList(placeIdList[i]));
      } catch (e) {
        print('detail add -$e');
      }
    }
    print('get place Detaillist');

    return Future.wait([...details] //리스트끼리 합친다.
        );
  }

  void _submit() {
    if (!_fbkey.currentState.validate()) {
      return; //_formKey라는 Globalkey를 등록한 Form이 유효하지 않으면 작동안함
    } //retrun ;으로 if문 의 종료를의미

    _fbkey.currentState.save();
    final inputValues = _fbkey.currentState.value;
    final id = inputValues['placeId'];
    // print(id);

    final foundPlace = places.firstWhere(
      (place) => place['id'] == id,
      orElse: () => null,
    ); //조건에 맞는 데이터 필터링

    _searchPlaces(foundPlace['placeName'], placeDetail.lat, placeDetail.lng);

    Navigator.of(context).pop();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
  }

  @override
  void initState() {
    getCurrentPosition();
    super.initState();
  }

  void _moveCamera() async {
    try {
      GoogleMapController controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(placeDetail.lat, placeDetail.lng)),
      );
    } catch (e) {
      print("error?? -$e");
    }

    print("noo - ${placeDetail.lat}");
    print("noo - ${placeDetail.lng}");

    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(placeDetail.name),
        position: LatLng(placeDetail?.lat, placeDetail.lng),
        infoWindow: InfoWindow(
            title: placeDetail.name, snippet: placeDetail.formattedAddress),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width * 0.75;

    return Scaffold(
      backgroundColor: backColor,
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
            centerTitle: true,
            title: Text(
              "골목지도",
              style: GoogleFonts.nanumGothic(color: kcolorgrey),
            ),
            backgroundColor: Colors.white,
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: kcolorgrey),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Transform.scale(
                  scale: 0.7,
                  child: SvgPicture.asset(
                    "assets/icons/send1.svg",
                    color: pointColor,
                  ),
                ),
                onPressed: () => getCurrentPosition(),
              ),
              Transform.rotate(
                angle: math.pi / 1,
                child: IconButton(
                  icon: Transform.scale(
                    scale: 0.6,
                    child: SvgPicture.asset(
                      'assets/icons/menu.svg',
                    ),
                  ),
                  onPressed: () => _scaffoldKey.currentState.openDrawer(),
                ),
              ),
            ]),
      ),
      drawer: ReviewDrawer(w: w),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 15),
              child: Container(
                width: w,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 3,
                          offset: Offset(0, 1)),
                    ]),
                child: placeInputFiled(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 15),
              child: IconButton(
                  icon: Icon(
                    Icons.search,
                    size: 30,
                  ),
                  onPressed: () => _moveCamera()),
            ),
          ],
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 20),
            height: MediaQuery.of(context).size.height,
            child: Stack(children: [
              GoogleMap(
                myLocationEnabled: true,
                mapType: _googleMapType,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.551052, 126.991568),
                  zoom: 12,
                ),
                markers: _markers,
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 120,
                  left: 10,
                ),
                alignment: Alignment.topLeft,
                child: Column(
                  children: <Widget>[
                    FloatingActionButton.extended(
                      onPressed: _allayShop,
                      label: Text(
                        "근처의 가게찾기",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      elevation: 3,
                      backgroundColor: pointColor,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
        placeInfomation() //메서드 추출해서빼기
      ]),
    );
  }

  Widget placeInfomation() {
    return SlidingUpPanel(
        controller: panelController,
        maxHeight: 270,
        minHeight: 110,
        borderRadius: BorderRadius.only(topRight: Radius.circular(40)),
        panel: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(top: 21, left: 25),
                child: Text(
                  placeDetail?.name ?? "현재위치", //널 세이프티하게 처리
                  style: GoogleFonts.nanumGothic(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 25),
                    child: Text(
                      '리뷰많은 순으로 보기',
                      style: GoogleFonts.nanumGothic(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 25),
                    child: IconButton(
                        icon: Icon(Icons.expand_more), onPressed: () {}),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                    itemCount: placeNearbyList.length,
                    itemBuilder: (context, index) {
                      PlaceNearby placeNearList = this.placeNearbyList[index];
                      print('placeList =$placeNearList');
                      return Container(
                        height: 120,
                        margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey[100].withAlpha(150),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(children: [
                          if (placeNearList.photoReference != null)
                            Image.network(
                              placeNearList.photoReference,
                              fit: BoxFit.fitWidth,
                              width: 120,
                              height: 120,
                            ),
                          if (placeNearList.photoReference == null)
                            Image.network(
                              placeNearList.icon,
                              fit: BoxFit.fitWidth,
                              width: 120,
                              height: 120,
                            ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    "${placeNearList.name}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                                IgnorePointer(
                                  child: RatingBar.builder(
                                      initialRating: placeNearList.rating,
                                      itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                      onRatingUpdate: (rating) {
                                        print(rating);
                                      }),
                                ),
                                Flexible(
                                  child: Container(),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        print(
                                            "place Idddd - ${placeNearList.placeId}");
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ReviewWritePageScreen(
                                                      placeNearby:
                                                          placeNearList,
                                                    )));
                                      },
                                      child: Text(
                                        "리뷰쓰기",
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Container(
                                        height: 15,
                                        width: 1,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (placeNearList.placeId != null)
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ReviewScreen(
                                                placeNearby: placeNearList,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            "리뷰보러가기",
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ])
                        ]),
                      );
                    }),
              ),
            ],
          ),
        ));
  }

  Widget placeInputFiled() {
    return TypeAheadField(
      debounceDuration: Duration(milliseconds: 500),
      textFieldConfiguration: TextFieldConfiguration(
        controller: _searchController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 10),
          border: InputBorder.none,
          hintText: '장소를 검색하세요', //검색시에 즐찾 가게를 찾을 수 있게
          hintStyle: GoogleFonts.nanumGothic(color: Colors.grey),
        ),
      ),
      suggestionsCallback: placeSugestion,
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion.description),
        );
      },
      onSuggestionSelected: (suggestion) async {
        try {
          placeDetail =
              await googleMapServices.getPlaceDetail(suggestion.placeId);
          sessionToken = null;
          _moveCamera();
        } catch (e) {
          print("error111 -$e");
        }
      },
    );
  }

  FutureOr<List<Place>> placeSugestion(String pattern) async {
    if (sessionToken == null) {
      sessionToken = uuid.v4();
    }
    googleMapServices = GoogleMapServices(sessionToken: sessionToken);
    return await googleMapServices.getSuggestions(pattern);
  }

  Widget buildSlidingPanel({@required PanelController panelController}) {
    return GestureDetector(
      onTap: panelController.open,
    );
  }
}
