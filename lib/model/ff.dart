// Future<List<PlaceNearby>> getPlaceNearbyList(String locationName, double latitude, double longitude) async {
//   final String nearurl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
//   String _url =  "$nearurl?key=$API_KEY&location=$latitude,$longitude&radius=1500&language=ko&keyword=$locationName";
//   try {
//     final http.Response _resposenear = await http.get(_url);
//     final _responseData = json.decode(_resposenear.body);
//     final result = _responseData['results'];
//     List<PlaceNearby> placeNear = result.map((data) => PlaceNearby.fromJson(data)).toList();
//
//     List<PlaceNearby> placeIdList= [];
//     for(int i =0; i <placeNear.length; i++) {
//      final placenear = PlaceNearby.fromJson(result[i]);
//      placeIdList.add(placenear);
//     }
//     return placeIdList;
//   } catch(e) {
//     print(e);
//   }
// return null;
// }


// print("url- $url");
// print("search api response code - ${_response.statusCode}");
// print("search api response code - ${_response.body}");
// print('responseData - $data');
// print("reult -${data["results"]}");

 // List<PlaceNearby> placeIdMockList= [
//   PlaceNearby(placeId: "placeId1", lat: 35.68, lng: 36.32, name: "우리동네", vicinity: "2"),
//   PlaceNearby(placeId: "placeId2", lat: 37.68, lng: 35.32, name: "너네동네", vicinity: "서울")
// ];