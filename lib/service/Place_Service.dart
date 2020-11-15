import 'package:alleymap_app/model/place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class PlaceService {
  FirebaseFirestore db = FirebaseFirestore.instance;
  BehaviorSubject behaviorSubject = BehaviorSubject();

  Future listPlace() async {
    QuerySnapshot querySnapshot =await db.collection('place').limit(50).get();
    List<QueryDocumentSnapshot> docs = querySnapshot.docs;

    List<PlaceNearby> placeNearbyList =
    docs.map((doc) => PlaceNearby.fromFirebase(doc.data())).toList();

    print('place Nearby list -${placeNearbyList.length}');
    return placeNearbyList;
  }
  
 Stream<List<DocumentSnapshot>> listPlacebyLocation(LatLng lanLng) {
    var ref = db.collection('place');

    Geoflutterfire geo = Geoflutterfire();

   GeoFirePoint geoFirePoint = geo.point(
        latitude: lanLng.latitude,
        longitude: lanLng.longitude);

   behaviorSubject.add(5.0);

   return behaviorSubject.switchMap((radius) {
     return geo.collection(collectionRef: ref).within(
         center: geoFirePoint, radius: radius, field: 'location');
   });
  }
}