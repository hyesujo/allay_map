import 'dart:convert';
import 'package:alleymap_app/model/place.dart';
import 'package:http/http.dart' as http;

import 'package:alleymap_app/constant.dart';


class GoogleMapServices {
  final String sessionToken;

  GoogleMapServices({
    this.sessionToken
});

  Future<List> getSuggestions(String query) async {
    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String type = 'establishment';
    String url =
        '$baseUrl?input=$query&key=$API_KEY&type=$type&language=ko&components=country:kr&sessiontoken=$sessionToken';

    print(url);

    final http.Response response = await http.get(url);
    final responseData = json.decode(response.body);
    final predictions = responseData['predictions'];

    List<Place> suggestions = [];

    for(int i = 0; i < predictions.length; i ++) {
      final place = Place.fromJson(predictions[i]);
      suggestions.add(place);
    }

    return suggestions;
  }

  // -> 어떻게 분기해야하는가? 값으로 인식 -> 있다 || 없다 -> 있는데 원하는 값이다 || 아니다
  // if(getPlaceDetail(...) == null) ... 다
  // else{
  //  if(getPlaceDetail(...) == 조건){
  //  }
  // }
  Future<PlaceDetail> getPlaceDetail(String placeId, String token) async {
    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/details/json';
   String url =
        '$baseUrl?key=$API_KEY&place_id=$placeId&language=ko&sessiontoken=$token';
   // --> final String _url ='$baseUrl?key=$API_KEY&place_id=$placeId&language=ko&sessiontoken=$token';
    print('Place Detail(sessionToken): $sessionToken');
    // 예외처리
    // -> public || private

    try{
      final http.Response _response = await http.get(url);
      final _responseData = json.decode(_response.body);
      print('response data - $_responseData');
      final result = _responseData['result'];
      print('result : $result');
      // final PlaceDetail placeDetail = PlaceDetail.fromJson(result);
      // print(placeDetail.toMap());
      // return placeDetail;
      return PlaceDetail.fromJson(result);
    }
    catch(e){
      return null;
    }
  }

}