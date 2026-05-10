import 'package:cloud_firestore/cloud_firestore.dart';

class AppTip {
  final String id;
  final String title;
  final String content;
  final bool isVip;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AppTip({
    required this.id,
    required this.title,
    required this.content,
    required this.isVip,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory AppTip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppTip(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      isVip: data['isVip'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title.trim(),
      'content': content.trim(),
      'isVip': isVip,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
