import 'package:alleymap_app/model/review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewService {
  FirebaseFirestore fbstore = FirebaseFirestore.instance;

  Future<List<Review>> getReview(String placeId) async {
    QuerySnapshot snapshot = await fbstore
        .collection("reviews")
        .where('placeId', isEqualTo: placeId)
        .get();

    List<QueryDocumentSnapshot> docs = snapshot.docs;

    List<Review> reviewList =
        docs.map((doc) => Review.fromMap(doc.data())).toList();
    print("review docs -${docs.length}");

    return reviewList;
  }
}
