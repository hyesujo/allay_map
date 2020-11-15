class Review {
  String placeId;
  String content;
  String photoUrl;
  double rating;

  Review({this.placeId, this.rating, this.photoUrl, this.content});

  Review.fromMap(Map<String, dynamic> map) {
    this.placeId = map['placeId'];
    this.content = map['content'];
    this.photoUrl = map['photoUrl'];
    this.rating = map['rating'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['placeId'] = this.placeId;
    map['content'] = this.content;
    map['photoUrl'] = this.photoUrl;
    map['rating'] = this.rating;
    return map;
  }
}
