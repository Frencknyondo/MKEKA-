import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, tipster, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isVip;
  final bool emailVerified;
  final DateTime? subscriptionEnd;
  final String? photoUrl;
  final bool isActive;
  final String? fcmToken;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isVip,
    required this.emailVerified,
    this.subscriptionEnd,
    this.photoUrl,
    this.isActive = true,
    this.fcmToken,
    required this.createdAt,
  });

  bool get isSubscriptionActive {
    if (!isVip) return false;
    if (subscriptionEnd == null) return false;
    return subscriptionEnd!.isAfter(DateTime.now());
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == (data['role'] ?? 'user'),
        orElse: () => UserRole.user,
      ),
      isVip: data['isVip'] ?? false,
      emailVerified: data['emailVerified'] ?? false,
      subscriptionEnd: data['subscriptionEnd'] != null
          ? (data['subscriptionEnd'] as Timestamp).toDate()
          : null,
      photoUrl: data['photoUrl'],
      isActive: data['isActive'] ?? true,
      fcmToken: data['fcmToken'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'isVip': isVip,
      'emailVerified': emailVerified,
      'subscriptionEnd':
          subscriptionEnd != null ? Timestamp.fromDate(subscriptionEnd!) : null,
      'photoUrl': photoUrl,
      'isActive': isActive,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppUser copyWith({
    String? name,
    UserRole? role,
    bool? isVip,
    bool? emailVerified,
    DateTime? subscriptionEnd,
    String? photoUrl,
    bool? isActive,
    String? fcmToken,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role ?? this.role,
      isVip: isVip ?? this.isVip,
      emailVerified: emailVerified ?? this.emailVerified,
      subscriptionEnd: subscriptionEnd ?? this.subscriptionEnd,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}
