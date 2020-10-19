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

  var sessionToken;

  var uuid = Uuid();

  PlaceDetail placeDetail;
  PlaceNearby placeNearby;

  var googleMapServices;

  void getCurrentPosition() async {
    var pos = await location.getLocation();
    setState(() {
      currentPos = LatLng(
        pos.latitude,
        pos.longitude,
      );
    });
    print('google map - ${currentPos.latitude}');

    var mapctrl = await _mapController.future;
    mapctrl.animateCamera(
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

  Future<PlaceNearby> _searchPlaces(String locationName, double latitude, double longitude) async {
    final String nearUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    String url =
        "$nearUrl?key=$API_KEY&location=$latitude,$longitude&radius=1500&language=ko&keyword=$locationName";

    try {
      final http.Response _response = await http.get(url);

      if (_response.statusCode == 200) {
        final data = json.decode(_response.body);
        print('responseData - $data');

        if (data['status'] == 'OK') {
          GoogleMapController controller = await _mapController.future;
          controller.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(latitude, longitude),
            ),
          );

          print('place nearby - $placeDetail ,  ${placeNearby?.result}');
          final foundPlaces = placeNearby.result;

          for(int i =0; i <foundPlaces.length; i++) {
            final mark = PlaceNearby.fromJson(foundPlaces[i]);
            _markers.add(
                Marker(
                  markerId: MarkerId(placeNearby.id),
                  position: LatLng(
                    placeNearby.lat,
                    placeNearby.lng,
                  ),
                  infoWindow: InfoWindow(
                      title: placeNearby.name,
                      snippet: placeNearby.vicinity
                  ),
                )
            );
            return mark;
          }

          setState(() {
            _markers;
          });
        }
      } else {
        print('Fail to fetch place data');
      }
    } catch (e) {
      return null;
    }
  }

  void _submit() {
    if (!_fbkey.currentState.validate()) {
      return;
    }

    _fbkey.currentState.save();
    final inputValues = _fbkey.currentState.value;
    final id = inputValues['placeId'];
    print(id);

    final foundPlace = places.firstWhere(
      (place) => place['id'] == id,
      orElse: () => null,
    );

    print(foundPlace['placeName']);

    print('place detail - lat ${placeDetail.lat}, lng ${placeDetail.lng}');
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
            )),
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
      CameraUpdate.newLatLng(LatLng(placeDetail.lat, placeDetail.lng)),
    );

    setState(() {
      _markers.add(Marker(
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
                child: TypeAheadField(
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
                  suggestionsCallback: (pattern) async {
                    if (sessionToken == null) {
                      sessionToken = uuid.v4();
                    }
                    googleMapServices =
                        GoogleMapServices(sessionToken: sessionToken);
                    return await googleMapServices.getSuggestions(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.description),
                    );
                  },
                  onSuggestionSelected: (suggestion) async {
                    placeDetail = await googleMapServices.getPlaceDetail(
                        suggestion.placeId, sessionToken);
                    sessionToken = null;
                    _moveCamera();
                  },
                ),
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
        SlidingUpPanel(
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
                    placeDetail?.name ?? "현재위치", //지도에 현재 위치 표시, null없애기ㅠ
                    style: GoogleFonts.nanumGothic(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(children: [
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
                  )
                ]),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
