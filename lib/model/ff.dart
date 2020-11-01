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