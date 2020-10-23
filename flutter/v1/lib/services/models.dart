import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  Map<String, dynamic> data;

  String id;
  String uid;
  String category;

  String title;
  String content;

  int like;
  int dislike;

  Timestamp createdAt;
  Timestamp updatedAt;

  List<dynamic> comments = [];

  PostModel({
    this.id,
    this.uid,
    this.category,
    this.title,
    this.content,
    this.like,
    this.dislike,
    this.createdAt,
    this.updatedAt,
    this.data,
  });

  factory PostModel.fromDocument(dynamic data) {
    return PostModel(
      id: data['id'],
      uid: data['uid'],
      category: data['category'],
      title: data['title'],
      content: data['content'] ?? '',
      like: data['like'] ?? 0,
      dislike: data['dislike'] ?? 0,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      data: data,
    );
  }

  @override
  String toString() {
    return this.data.toString();
  }
}
