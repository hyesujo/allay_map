import '../constant.dart';

class Place {
  String description;
  final String placeId;

  Place({
    this.description,
    this.placeId,
  });

  //:은 assert

  Place.fromJson(Map<String, dynamic> json)
      : this.description = json['description'],
        this.placeId = json['placeId'];

  // factory Place.fromJson2(Map<String, dynamic> json) {
  //   return Place(
  //     description: json['description'],
  //     placeId: json['place_id']
  //   );
  // } //인스턴스를 만드는것

  Map<String, dynamic> tomap() {
    return {'description': this.description, 'placeId': this.placeId};
  }
}

class PlaceDetail {
  final String formattedAddress;
  final String formattedPhoneNumber;
  final String name;
  final String vicinity;
  final String website;
  final double lat;
  final double lng;
  final double rating;
  final List reviews;
  final String icon;

  PlaceDetail({
    this.formattedAddress,
    this.formattedPhoneNumber,
    this.name,
    this.vicinity,
    this.website = '',
    this.reviews,
    this.lat,
    this.lng,
    this.rating,
    this.icon,
  });

  factory PlaceDetail.fromJson(Map<String, dynamic> json) => PlaceDetail(
        formattedAddress: json['formatted_address'],
        formattedPhoneNumber: json['formatted_phone_number'],
        name: json['name'] ?? '현재위치',
        vicinity: json['vicinity'],
        reviews: json['reviews'],
        website: json['website'] ?? '',
        lat: json['geometry']['location']['lat'] ?? 0.0,
        lng: json['geometry']['location']['lng'] ?? 0.0,
        rating: json['rating'] ?? 0.0,
        icon: json["icon"],
      );

  Map<String, dynamic> toMap() {
    return {
      'formattedAddress': this.formattedAddress,
      'formattedPhoneNumber': this.formattedPhoneNumber,
      'name': this.name,
      'vicinity': this.vicinity,
      'website': this.website,
      'lat': this.lat,
      'lng': this.lng,
      'icon': this.icon,
      'reviews': this.reviews
    };
  }
}

class PlaceNearby {
  final String placeId;
  final double lat;
  final double lng;
  final String name;
  String icon;
  final String vicinity;
  double rating = 0.0;
  String photoReference;

  PlaceNearby(
      {this.placeId,
      this.lat,
      this.lng,
      this.name,
      this.photoReference,
      this.vicinity,
      this.rating,
      this.icon});

  factory PlaceNearby.fromJson(Map<String, dynamic> json) => PlaceNearby(
      placeId: json['place_id'],
      lat: json['geometry']['location']['lat'],
      lng: json['geometry']['location']['lng'],
      name: json['name'],
      vicinity: json['vicinity']);

  factory PlaceNearby.fromFirebase(Map<String, dynamic> json) {
    print("place data - $json");

    return PlaceNearby(
        placeId: json['placeId'],
        lat: json['lat'],
        lng: json['lng'],
        name: json['name'],
        photoReference: getPhotoUrl(json['photoReference']) ?? null,
        vicinity: json['vicinity'],
        rating: json['rating'],
        icon: json['icon']);
  }

  static String getPhotoUrl(String photoRef) {
    if (photoRef == null) {
      return null;
    }
    String url =
        "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoRef&key=$API_KEY";
    return url;
  }
}
