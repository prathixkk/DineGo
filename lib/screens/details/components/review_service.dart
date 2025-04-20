import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(XFile imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child("review_images/$fileName.jpg");

    await ref.putFile(File(imageFile.path));
    return await ref.getDownloadURL();
  }

  Future<void> submitReview({
    required String restaurantId,
    required String foodName,
    required String userId,
    required String userName,
    required String userAvatar,
    required double rating,
    required String comment,
    XFile? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await uploadImage(imageFile);
    }

    final reviewData = {
      "restaurantId": restaurantId,
      "foodName": foodName,
      "userId": userId,
      "userName": userName,
      "userAvatar": userAvatar,
      "rating": rating,
      "comment": comment,
      "imageUrl": imageUrl ?? '',
      "likes": [],
      "dislikes": [],
      "timestamp": FieldValue.serverTimestamp(),
      "replies": [],
    };

    await _firestore.collection("reviews").add(reviewData);
  }
}
