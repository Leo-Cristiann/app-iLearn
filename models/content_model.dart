import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  final String id;
  final String title;
  final String contentType;
  final String content;
  final int? duration;
  final int views;
  final int likes;
  final int downloads;

  ContentModel({
    required this.id,
    required this.title,
    required this.contentType,
    required this.content,
    this.duration,
    this.views = 0,
    this.likes = 0,
    this.downloads = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'contentType': contentType,
      'content': content,
      'duration': duration,
      'views': views,
      'likes': likes,
      'downloads': downloads,
    };
  }

  factory ContentModel.fromMap(Map<String, dynamic> map) {
    return ContentModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      contentType: map['contentType'] ?? '',
      content: map['content'] ?? '',
      duration: map['duration'],
      views: map['views'] ?? 0,
      likes: map['likes'] ?? 0,
      downloads: map['downloads'] ?? 0,
    );
  }
}