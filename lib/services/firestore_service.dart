import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/mkeka_model.dart';
import '../models/tip_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const _uuid = Uuid();

  // ─── MKEKAS ──────────────────────────────────────────────────────────────────

  /// Stream of free mkekas for Home screen
  static Stream<List<Mkeka>> streamFreeMkekas() {
    return _db
        .collection('mkekas')
        .where('isVip', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((s) => s.docs.map(Mkeka.fromFirestore).toList());
  }

  /// Stream of VIP mkekas — only for VIP users
  static Stream<List<Mkeka>> streamVipMkekas() {
    return _db
        .collection('mkekas')
        .where('isVip', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((s) => s.docs.map(Mkeka.fromFirestore).toList());
  }

  /// Stream of all mkekas (free + vip) for home — use with VIP check
  static Stream<List<Mkeka>> streamAllMkekas() {
    return _db
        .collection('mkekas')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((s) => s.docs.map(Mkeka.fromFirestore).toList());
  }

  /// Stream of featured mkekas
  static Stream<List<Mkeka>> streamFeaturedMkekas() {
    return _db
        .collection('mkekas')
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((s) => s.docs.map(Mkeka.fromFirestore).toList());
  }

  /// Stream of a tipster's own mkekas
  static Stream<List<Mkeka>> streamTipsterMkekas(String tipsterId) {
    return _db
        .collection('mkekas')
        .where('tipsterId', isEqualTo: tipsterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Mkeka.fromFirestore).toList());
  }

  // ─── POST MKEKA ──────────────────────────────────────────────────────────────

  /// Upload images to Firebase Storage and post mkeka
  static Future<PostResult> postMkeka({
    required AppUser tipster,
    required String title,
    required List<File> imageFiles, // 2-3 screenshots
    String? description,
    required bool isVip,
    double? totalOdds,
    DateTime? matchDate,
  }) async {
    try {
      if (imageFiles.isEmpty || imageFiles.length > 3) {
        return PostResult(
            success: false, message: 'Weka picha 2 au 3 za mkeka wako.');
      }

      // Upload images to Storage
      final List<String> imageUrls = [];
      for (final file in imageFiles) {
        final fileName = '${_uuid.v4()}.jpg';
        final ref = _storage.ref('mkekas/${tipster.id}/$fileName');
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      // Create Firestore document
      final mkeka = Mkeka(
        id: '',
        tipsterId: tipster.id,
        tipsterName: tipster.name,
        tipsterPhotoUrl: tipster.photoUrl,
        title: title.trim(),
        imageUrls: imageUrls,
        description: description?.trim(),
        isVip: isVip,
        isFeatured: false,
        status: MkekaStatus.pending,
        totalOdds: totalOdds,
        createdAt: DateTime.now(),
        matchDate: matchDate,
      );

      await _db.collection('mkekas').add(mkeka.toMap());

      // Update tipster stats
      await _db.collection('tipsters').doc(tipster.id).set({
        'userId': tipster.id,
        'displayName': tipster.name,
        'totalPredictions': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return PostResult(success: true, message: 'Mkeka wako umechapishwa!');
    } catch (e) {
      return PostResult(
          success: false, message: 'Imeshindwa kuchapisha. Jaribu tena.');
    }
  }

  static Future<PostResult> postMkekaWithImageUrls({
    required AppUser tipster,
    required String title,
    required List<String> imageUrls,
    String? description,
    required bool isVip,
    double? totalOdds,
    DateTime? matchDate,
  }) async {
    try {
      final cleanUrls = imageUrls
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      if (cleanUrls.isEmpty || cleanUrls.length > 3) {
        return PostResult(
            success: false, message: 'Weka link 1 hadi 3 za picha za mkeka.');
      }

      final mkeka = Mkeka(
        id: '',
        tipsterId: tipster.id,
        tipsterName: tipster.name,
        tipsterPhotoUrl: tipster.photoUrl,
        title: title.trim(),
        imageUrls: cleanUrls,
        description: description?.trim(),
        isVip: isVip,
        isFeatured: false,
        status: MkekaStatus.pending,
        totalOdds: totalOdds,
        createdAt: DateTime.now(),
        matchDate: matchDate,
      );

      await _db.collection('mkekas').add(mkeka.toMap());
      await _db.collection('tipsters').doc(tipster.id).set({
        'userId': tipster.id,
        'displayName': tipster.name,
        'totalPredictions': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return PostResult(success: true, message: 'Mkeka wako umechapishwa!');
    } catch (e) {
      return PostResult(success: false, message: 'Imeshindwa kuchapisha: $e');
    }
  }

  // ─── UPDATE MKEKA STATUS ──────────────────────────────────────────────────────

  static Future<void> updateMkekaStatus(
      String mkekaId, MkekaStatus status) async {
    await _db.collection('mkekas').doc(mkekaId).update({
      'status': status.name,
    });

    // If won, increment tipster wonCount and recalculate win rate
    if (status == MkekaStatus.won) {
      final mkeka = await _db.collection('mkekas').doc(mkekaId).get();
      final tipsterId = (mkeka.data() as Map)['tipsterId'];
      if (tipsterId != null) {
        await _db.collection('tipsters').doc(tipsterId).update({
          'wonCount': FieldValue.increment(1),
        });
        await _recalculateWinRate(tipsterId);
      }
    }
  }

  static Future<void> toggleMkekaFeatured(
      String mkekaId, bool isFeatured) async {
    await _db.collection('mkekas').doc(mkekaId).update({
      'isFeatured': isFeatured,
    });
  }

  static Future<void> deleteMkeka(String mkekaId) async {
    await _db.collection('mkekas').doc(mkekaId).delete();
  }

  static Future<void> _recalculateWinRate(String tipsterId) async {
    final tipsterDoc = await _db.collection('tipsters').doc(tipsterId).get();
    if (!tipsterDoc.exists) return;
    final data = tipsterDoc.data() as Map<String, dynamic>;
    final total = (data['totalPredictions'] as int?) ?? 0;
    final won = (data['wonCount'] as int?) ?? 0;
    if (total == 0) return;
    final winRate = (won / total * 100).round();
    await _db
        .collection('tipsters')
        .doc(tipsterId)
        .update({'winRate': winRate});
  }

  // ─── VIP / SUBSCRIPTION ──────────────────────────────────────────────────────

  /// Grant VIP to user (called after payment confirmed)
  static Future<void> grantVip({
    required String userId,
    required String plan, // daily | weekly | monthly
    required String paymentMethod,
    required String transactionRef,
  }) async {
    final now = DateTime.now();
    DateTime endDate;
    int amount;

    switch (plan) {
      case 'daily':
        endDate = now.add(const Duration(days: 1));
        amount = 1000;
        break;
      case 'weekly':
        endDate = now.add(const Duration(days: 7));
        amount = 3000;
        break;
      case 'monthly':
      default:
        endDate = now.add(const Duration(days: 30));
        amount = 10000;
        break;
    }

    // Update user VIP status
    await _db.collection('users').doc(userId).update({
      'isVip': true,
      'subscriptionEnd': Timestamp.fromDate(endDate),
    });

    // Save subscription record
    await _db.collection('subscriptions').add({
      'userId': userId,
      'plan': plan,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'transactionRef': transactionRef,
      'startDate': Timestamp.fromDate(now),
      'endDate': Timestamp.fromDate(endDate),
      'status': 'active',
    });
  }

  /// Check and revoke expired VIP (call on app start)
  static Future<void> checkVipExpiry(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final isVip = data['isVip'] ?? false;
    if (!isVip) return;
    final subEnd = data['subscriptionEnd'];
    if (subEnd == null) return;
    final endDate = (subEnd as Timestamp).toDate();
    if (endDate.isBefore(DateTime.now())) {
      await _db.collection('users').doc(userId).update({'isVip': false});
    }
  }

  // ─── ADMIN / USERS ──────────────────────────────────────────────────────────

  static Stream<List<AppUser>> streamUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AppUser.fromFirestore).toList());
  }

  static Future<void> createUserRecord({
    required String name,
    required String email,
    required UserRole role,
  }) async {
    final doc = _db.collection('users').doc();
    final user = AppUser(
      id: doc.id,
      name: name.trim(),
      email: email.trim(),
      role: role,
      isVip: false,
      emailVerified: false,
      isActive: true,
      createdAt: DateTime.now(),
    );
    await doc.set(user.toMap());
  }

  static Future<void> updateUserRole({
    required String userId,
    required UserRole role,
  }) async {
    await _db.collection('users').doc(userId).update({'role': role.name});

    if (role == UserRole.tipster) {
      await _db.collection('tipsters').doc(userId).set({
        'userId': userId,
        'status': 'active',
        'followers': 0,
        'winRate': 0,
        'totalPredictions': 0,
        'wonCount': 0,
        'verified': false,
        'isFeatured': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // ─── TIPSTERS ────────────────────────────────────────────────────────────────

  static Stream<List<Map<String, dynamic>>> streamTopTipsters() {
    return _db
        .collection('tipsters')
        .where('status', isEqualTo: 'active')
        .orderBy('winRate', descending: true)
        .limit(10)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  static Future<void> applyAsTipster({
    required String userId,
    required String name,
    required String bio,
  }) async {
    await _db.collection('tipsters').doc(userId).set({
      'userId': userId,
      'displayName': name,
      'bio': bio,
      'followers': 0,
      'winRate': 0,
      'totalPredictions': 0,
      'wonCount': 0,
      'verified': false,
      'isFeatured': false,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('users').doc(userId).update({'role': 'tipster'});
  }

  // Tips

  static Stream<List<AppTip>> streamTips({bool includeInactive = false}) {
    return _db
        .collection('tips')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final tips = snapshot.docs.map(AppTip.fromFirestore).toList();
      if (includeInactive) return tips;
      return tips.where((tip) => tip.isActive).toList();
    });
  }

  static Stream<List<AppTip>> streamVisibleTips(AppUser user) {
    return streamTips().map((tips) {
      return tips
          .where((tip) => !tip.isVip || user.isSubscriptionActive)
          .toList();
    });
  }

  static Future<void> addTip({
    required String title,
    required String content,
    required bool isVip,
    required bool isActive,
  }) async {
    final tip = AppTip(
      id: '',
      title: title,
      content: content,
      isVip: isVip,
      isActive: isActive,
      createdAt: DateTime.now(),
    );
    await _db.collection('tips').add(tip.toMap());
  }

  static Future<void> updateTip({
    required String tipId,
    required String title,
    required String content,
    required bool isVip,
    required bool isActive,
  }) async {
    await _db.collection('tips').doc(tipId).update({
      'title': title.trim(),
      'content': content.trim(),
      'isVip': isVip,
      'isActive': isActive,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  static Future<void> deleteTip(String tipId) async {
    await _db.collection('tips').doc(tipId).delete();
  }
}

class PostResult {
  final bool success;
  final String message;
  PostResult({required this.success, required this.message});
}
