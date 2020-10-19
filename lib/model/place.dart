class Place {
   String description;
  final String placeId;

  Place({
    this.description,
    this.placeId,
});

  //:은 assert

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

 factory PlaceDetail.fromJson(Map<String, dynamic> json) => 
     PlaceDetail(
        formattedAddress: json['formatted_address'],
       formattedPhoneNumber: json['formatted_phone_number'],
       name: json['name'] ??'현재위치',
       vicinity: json['vicinity'],
       website: json['website'] ??'',
       lat: json['geometry']['location']['lat'] ?? 0.0,
       lng : json['geometry']['location']['lng'],
      );
       

  Map<String, dynamic> toMap(){
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
  final Map<String,dynamic> result;
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


 factory PlaceNearby.fromJson(Map<String, dynamic> json) =>
  PlaceNearby(
    result: json['result'],
    id: json['id'],
    lat: json['geometry']['location']['lat'],
    lng: json['geometry']['location']['lng'],
    name: json['name'],
    vicinity: json['vicinity']
  );

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


