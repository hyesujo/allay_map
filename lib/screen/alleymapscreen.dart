import 'dart:async';
import 'dart:convert';
import 'package:alleymap_app/config.dart';
import 'package:alleymap_app/constant.dart';
import 'package:alleymap_app/model/place.dart';
import 'package:alleymap_app/service/googlemapService.dart';
import 'package:alleymap_app/widget/ReviewDrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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

  List<PlaceNearby> placeIdList= [];
  var uuid = Uuid();

  dynamic sessionToken;

  PlaceDetail placeDetail; //선언만 해준 상태이니 인스턴스 화를 해줘야 함
  PlaceNearby placeNearby;

  GoogleMapServices googleMapServices;

  void getCurrentPosition() async {
    LocationData pos = await location.getLocation();
    setState(() {
      currentPos = LatLng(
        pos.latitude,
        pos.longitude,
      );
    });

    placeDetail = PlaceDetail(lng: pos.longitude, lat: pos.latitude); //placeDetail 인스턴스화함
    print('google map - ${currentPos.latitude}');

    GoogleMapController mapCtrl = await _mapController.future;
    mapCtrl.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                currentPos.latitude,
                currentPos.longitude),
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

  void _searchPlaces(String locationName, double latitude, double longitude)
  async {
    _markers.clear();

    final String nearUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    String _url =
        "$nearUrl?key=$API_KEY&location=$latitude,$longitude&radius=1500&language=ko&keyword=$locationName";

    // print("url- $url");
    // print("search api response code - ${_response.statusCode}");
    // print("search api response code - ${_response.body}");
    // print('responseData - $data');
    // print("reult -${data["results"]}");

    try {
      final http.Response _response = await http.get(_url);
      if (_response.statusCode == 200) {
        final data = json.decode(_response.body);

        List<dynamic> result = data["results"]; //다이나믹 리스트 형태로 받아옴

        List<PlaceNearby> placeNear = result.map((data) => PlaceNearby.fromJson(data)).toList(); //PlaceNearby를 인스턴스화함 .
        //result를 PlaceNearby클래스로 변경해서 받아줌

        List<String> placeIdList= [];

        for(int i =0; i <placeNear.length; i++) {
          PlaceNearby placeNearby = placeNear[i];
          placeIdList.add(placeNearby.placeId);
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
                    //  print("${placeNearby.name}");
                     // googleMapServices.getPlaceDetailList(placeNearby.placeId);
                    }
                ),
              ),
          );
          // googleMapServices.getPlaceDetailList(placeNearby.placeId);
        }//내가 준비한 데이터를 지도위에 보여주기 위해서 임

          setState(() {
            _markers;
          });
      } else {
        print('Fail to fetch place data');
      } } catch (e) {
      print(e);
    }

  }

  // void getPlaceDetailList(List<String> placeIdList) {
  //
  //   List details = [];
  //
  //   for(int i =0; i <placeIdList.length; i ++) {
  //     details.add(googleMapServices.getPlaceDetailList(placeIdList[i]));
  //   }
  //   Future.wait([googleMapServices.getPlaceDetailList("placeId")]); //future를 여러개 동시에 쓸수 있는 네트워크요청
  // }

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
    );  //조건에 맞는 데이터 필터링

    _searchPlaces(foundPlace['placeName'], placeDetail.lat, placeDetail.lng);

    Navigator.of(context).pop();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);

    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId('0'),
            infoWindow: InfoWindow(
              title: "동네",
              snippet: "흥미로운 곳",
            ),
        ),
      );
    });
  }

  @override
  void initState() {
    getCurrentPosition();
    super.initState();
  }

  void _moveCamera() async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(
          LatLng(placeDetail?.lat, placeDetail.lng)),
    );

    setState(() {
      _markers.add(
          Marker(
        markerId: MarkerId(placeDetail.name),
        position: LatLng(placeDetail.lat, placeDetail.lng),
        infoWindow: InfoWindow(
            title: placeDetail.name,
            snippet: placeDetail.formattedAddress),
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
              icon: Icon(
                  Icons.arrow_back,
                  color: kcolorgrey
              ),
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
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 30,
                  left: 15
              ),
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
                          offset: Offset(0, 1)
                      ),
                    ]),
                child:placeInputFiled(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 30,
                  left: 15),
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
            child: Stack(
                children: [
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
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),
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
        SlidingUpPanel(
          maxHeight: 270,
          minHeight: 110,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(40)
          ),
          panel: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(
                      top: 21,
                      left: 25
                  ),
                  child: Text(
                    placeDetail?.name ?? "현재위치", //널 세이프티하게 처리
                    style: GoogleFonts.nanumGothic(
                        fontSize: 28,
                        fontWeight: FontWeight.bold
                    ),
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
                        icon: Icon(Icons.expand_more),
                        onPressed: () {}),
                  )
                ]
                ),
                SizedBox(height: 10),
                // ListView.builder(
                //   itemCount: this.placeIdList.length,
                //     itemBuilder: (context,index) {
                //  final placelist = this.placeIdList[index];
                //   return ListTile(
                //     title: Text(placelist.name),
                //      );
                // }),
    ],
          ),
        )
        )
          ]),
    );
  }

 Widget placeInputFiled()  {
    return TypeAheadField(
                debounceDuration: Duration(
                    milliseconds: 500
                ),
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
                  placeDetail = await googleMapServices.getPlaceDetail(
                      suggestion.placeId);
                  sessionToken = null;
                  _moveCamera();
                },
              );
  }

 FutureOr<List<Place>> placeSugestion(String pattern) async {
               if (sessionToken == null) {
                 sessionToken = uuid.v4();
               }
               googleMapServices =
                   GoogleMapServices(sessionToken: sessionToken);
               return await googleMapServices.getSuggestions(pattern);
             } //세션토큰이 필요없을거 같음.

}

