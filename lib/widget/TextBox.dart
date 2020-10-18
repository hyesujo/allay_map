
import 'dart:async';

import 'package:alleymap_app/model/place.dart';
import 'package:alleymap_app/service/googlemapService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';


class TextBox extends StatelessWidget {

  Completer<GoogleMapController> mcontroller = Completer() ;

  TextBox({
    this.mcontroller,
});


  final TextEditingController _searchController = TextEditingController();

  var sessionToken;

  var uuid = Uuid();

  PlaceDetail placeDetail;

  var googleMapServices;

  void _moveCamera() async{
   GoogleMapController controller = await mcontroller.future;
   controller.animateCamera(
    CameraUpdate.newLatLng(
      LatLng(placeDetail.lat, placeDetail.lng)
    ),
   );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width * 0.75;

    return Padding(
      padding: const EdgeInsets.only(
          top: 30,
          left: 15),
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
                  offset: Offset(0,1)
              ),
            ]
        ),
        child: TypeAheadField(
          debounceDuration: Duration(milliseconds: 500),
          textFieldConfiguration: TextFieldConfiguration(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10),
                border: InputBorder.none,
                hintText: '장소를 검색하세요',  //검색시에 즐찾 가게를 찾을 수 있게
                hintStyle: GoogleFonts.nanumGothic(
                color: Colors.grey
              ),
          ),
          ),
          suggestionsCallback: (pattern) async {
            if (sessionToken == null) {
              sessionToken = uuid.v4();
            }
            googleMapServices = GoogleMapServices(sessionToken: sessionToken);
            return await googleMapServices.getSuggestions(pattern);
          },
          itemBuilder: (context, suggetion) {
            return ListTile(
              title: Text(suggetion.description),
            );
          },
          onSuggestionSelected: (suggetion) async{
           placeDetail = await googleMapServices.getPlaceDetail(
               suggetion.placeId, sessionToken
           );
           sessionToken = null;
           _moveCamera();
          },
        ),
      ),
    );
  }
}
