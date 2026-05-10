import 'package:cloud_firestore/cloud_firestore.dart';

enum MkekaStatus { pending, won, lost, void_ }

class Mkeka {
  final String id;
  final String tipsterId;
  final String tipsterName;
  final String? tipsterPhotoUrl;
  final String title; // e.g. "Weekend Banker"
  final List<String> imageUrls; // 2-3 screenshots
  final String? description;
  final bool isVip;
  final bool isFeatured;
  final MkekaStatus status;
  final double? totalOdds;
  final DateTime createdAt;
  final DateTime? matchDate;

  Mkeka({
    required this.id,
    required this.tipsterId,
    required this.tipsterName,
    this.tipsterPhotoUrl,
    required this.title,
    required this.imageUrls,
    this.description,
    required this.isVip,
    required this.isFeatured,
    required this.status,
    this.totalOdds,
    required this.createdAt,
    this.matchDate,
  });

  factory Mkeka.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Mkeka(
      id: doc.id,
      tipsterId: data['tipsterId'] ?? '',
      tipsterName: data['tipsterName'] ?? '',
      tipsterPhotoUrl: data['tipsterPhotoUrl'],
      title: data['title'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      description: data['description'],
      isVip: data['isVip'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      status: MkekaStatus.values.firstWhere(
        (s) => s.name == (data['status'] ?? 'pending'),
        orElse: () => MkekaStatus.pending,
      ),
      totalOdds: (data['totalOdds'] as num?)?.toDouble(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      matchDate: data['matchDate'] != null
          ? (data['matchDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipsterId': tipsterId,
      'tipsterName': tipsterName,
      'tipsterPhotoUrl': tipsterPhotoUrl,
      'title': title,
      'imageUrls': imageUrls,
      'description': description,
      'isVip': isVip,
      'isFeatured': isFeatured,
      'status': status.name,
      'totalOdds': totalOdds,
      'createdAt': Timestamp.fromDate(createdAt),
      'matchDate': matchDate != null ? Timestamp.fromDate(matchDate!) : null,
    };
  }

  String get statusLabel {
    switch (status) {
      case MkekaStatus.won:
        return 'WON ✅';
      case MkekaStatus.lost:
        return 'LOST ❌';
      case MkekaStatus.void_:
        return 'VOID ⚪';
      case MkekaStatus.pending:
        return 'PENDING 🕐';
    }
  }
}
