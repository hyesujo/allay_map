class Place {
  final String description;
  final String placeId;

  Place({
    this.description,
    this.placeId,
});

  Place.fromJson(Map<String,dynamic> json)
  :this.description = json['description'],
  this.placeId = json['place_id'];

  Map<String, dynamic> tomap() {
    return {
      'description' : this.description,
      'placeId' : this.placeId
    };
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

  PlaceDetail({
    this.formattedAddress,
    this.formattedPhoneNumber,
    this.name,
    this.vicinity,
    this.website = '',
    this.lat,
    this.lng,
  });


  PlaceDetail.fromJson(Map<String, dynamic> json)
      : this.formattedAddress = json['formatted_address'],
        this.formattedPhoneNumber = json['formatted_phone_number'],
        this.name = json['name'] ?? "현재위치",
        this.vicinity = json['vicinity'],
        this.website = json['website'] ?? '',
        this.lat = json['geometry']['location']['lat'] ?? 0.0,
        this.lng = json['geometry']['location']['lng'];

  Map<String, dynamic> toMap() {
    return {
      'formateedAddress': this.formattedAddress,
      'formateedPhoneNumber': this.formattedPhoneNumber,
      'name': this.name,
      'vicinity': this.vicinity,
      'website': this.website,
      'lat': this.lat,
      'lng': this.lng,
    };
  }
}

class PlaceNearby {
  final String result;
  final String id;
  final double lat;
  final double lng;
  final String name;
  final String vicinity;

  PlaceNearby({
    this.result,
    this.id,
    this.lat,
    this.lng,
    this.name,
    this.vicinity
  });

  PlaceNearby.fromJson(Map<String, dynamic> json)
   :  this.result = json['result'],
        this.id = json['id'],
    this.lat = json['geometry']['location']['lat'],
    this.lng = json['geometry']['location']['lng'],
    this.name = json['name'],
    this.vicinity =json['vicinity'];

  Map<String, dynamic> tomap() {
    return {
      'result' :this.result,
      'id' : this.id,
      'lat' :this.lat,
      'lng' : this.lng,
      'name' : this.name,
      'vicinity' : this.vicinity,
    };
  }

}


