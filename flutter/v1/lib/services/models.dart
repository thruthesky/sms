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

  List<CommentModel> comments = [];

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

  factory PostModel.fromDocument(Map<String, dynamic> data) {
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

class CommentModel {
  String id;
  String uid;
  String content;
  String order;
  int depth;
  Timestamp createdAt;
  Timestamp updatedAt;

  CommentModel({
    this.id,
    this.uid,
    this.content,
    this.depth,
    this.order,
    this.createdAt,
    this.updatedAt,
  });
  factory CommentModel.fromDocument(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      uid: json['uid'],
      content: json['content'],
      depth: json['depth'],
      order: json['order'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
  @override
  String toString() {
    return "id: $id, uid: $uid, depth: $depth, order: $order, content: $content";
  }
}
