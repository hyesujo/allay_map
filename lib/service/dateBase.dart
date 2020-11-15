import 'package:alleymap_app/model/review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Future addPost(Review post) async {
    return await _db.collection("reviews").doc().set(post.toMap());
  }
}
