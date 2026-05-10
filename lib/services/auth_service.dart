import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream of Firebase user — used in main.dart to react to auth state
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current Firebase user
  static User? get currentUser => _auth.currentUser;

  // ─── REGISTER WITH EMAIL ────────────────────────────────────────────────────

  static Future<AuthResult> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      // Update display name
      await user.updateDisplayName(name.trim());

      // Send email verification
      await user.sendEmailVerification();

      // Create Firestore document
      final appUser = AppUser(
        id: user.uid,
        name: name.trim(),
        email: email.trim(),
        role: UserRole.user,
        isVip: false,
        emailVerified: false,
        isActive: true,
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(user.uid).set(appUser.toMap());

      return AuthResult(
        success: true,
        message: 'Akaunti imetengenezwa! Angalia email yako kuthibitisha.',
        requiresVerification: true,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _authError(e.code));
    } catch (e) {
      return AuthResult(
          success: false, message: 'Hitilafu imetokea. Jaribu tena.');
    }
  }

  // ─── LOGIN WITH EMAIL ────────────────────────────────────────────────────────

  static Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      // Force reload to get latest emailVerified status
      await user.reload();
      final refreshed = _auth.currentUser!;

      if (!refreshed.emailVerified) {
        return AuthResult(
          success: false,
          message: 'Thibitisha email yako kwanza. Angalia inbox yako.',
          requiresVerification: true,
        );
      }

      // Update emailVerified in Firestore
      await _db.collection('users').doc(user.uid).update({
        'emailVerified': true,
      });

      return AuthResult(success: true, message: 'Umefanikiwa kuingia!');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _authError(e.code));
    } catch (e) {
      return AuthResult(
          success: false, message: 'Hitilafu imetokea. Jaribu tena.');
    }
  }

  // ─── SIGN IN WITH GOOGLE ─────────────────────────────────────────────────────

  static Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(
            success: false, message: 'Umeghairi kuingia na Google.');
      }

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check if user already exists in Firestore
      final doc = await _db.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        // New Google user — create Firestore document
        final appUser = AppUser(
          id: user.uid,
          name: user.displayName ?? googleUser.displayName ?? 'Mtumiaji',
          email: user.email ?? googleUser.email,
          role: UserRole.user,
          isVip: false,
          emailVerified: true, // Google accounts are always verified
          photoUrl: user.photoURL,
          isActive: true,
          createdAt: DateTime.now(),
        );
        await _db.collection('users').doc(user.uid).set(appUser.toMap());
      } else {
        // Existing user — update photo if changed
        await _db.collection('users').doc(user.uid).update({
          'emailVerified': true,
          'photoUrl': user.photoURL,
        });
      }

      return AuthResult(
          success: true, message: 'Umefanikiwa kuingia na Google!');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _authError(e.code));
    } on PlatformException catch (e) {
      return AuthResult(success: false, message: _googleSignInError(e));
    } catch (e) {
      return AuthResult(
          success: false,
          message: 'Imeshindwa kuingia na Google: $e');
    }
  }

  // ─── RESEND VERIFICATION EMAIL ───────────────────────────────────────────────

  static Future<AuthResult> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult(
            success: false, message: 'Hakuna mtumiaji aliyeingia.');
      }
      await user.sendEmailVerification();
      return AuthResult(
        success: true,
        message: 'Email ya uthibitisho imetumwa tena. Angalia inbox yako.',
      );
    } catch (e) {
      return AuthResult(
          success: false, message: 'Imeshindwa kutuma email. Jaribu baadaye.');
    }
  }

  // ─── FORGOT PASSWORD ─────────────────────────────────────────────────────────

  static Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(
        success: true,
        message: 'Email ya kubadilisha nywila imetumwa. Angalia inbox yako.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _authError(e.code));
    } catch (e) {
      return AuthResult(
          success: false, message: 'Hitilafu imetokea. Jaribu tena.');
    }
  }

  // ─── SIGN OUT ────────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── GET USER DATA FROM FIRESTORE ────────────────────────────────────────────

  static Future<AppUser?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  static Future<void> markEmailVerified(String uid) async {
    await _db.collection('users').doc(uid).update({
      'emailVerified': true,
    });
  }

  // ─── STREAM USER DATA ────────────────────────────────────────────────────────

  static Stream<AppUser?> streamUserData(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }

  // ─── ERROR MESSAGES IN SWAHILI ───────────────────────────────────────────────

  static String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email hii tayari inatumika. Jaribu login au tumia email nyingine.';
      case 'invalid-email':
        return 'Muundo wa email si sahihi.';
      case 'weak-password':
        return 'Nywila ni dhaifu. Tumia herufi 6 au zaidi.';
      case 'user-not-found':
        return 'Hakuna akaunti na email hii. Jisajili kwanza.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email au nywila si sahihi.';
      case 'user-disabled':
        return 'Akaunti hii imezuiwa. Wasiliana na msaada.';
      case 'too-many-requests':
        return 'Majaribio mengi sana. Subiri dakika chache kisha jaribu tena.';
      case 'network-request-failed':
        return 'Hakuna mtandao. Angalia connection yako.';
      case 'operation-not-allowed':
        return 'Google Sign-In haijawashwa kwenye Firebase Console.';
      case 'account-exists-with-different-credential':
        return 'Email hii tayari ipo kwa njia nyingine ya kuingia.';
      default:
        return 'Hitilafu imetokea ($code). Jaribu tena.';
    }
  }

  static String _googleSignInError(PlatformException e) {
    final details = '${e.message ?? ''} ${e.details ?? ''}';
    if (details.contains('ApiException: 10') ||
        details.contains('DEVELOPER_ERROR')) {
      return 'Google Sign-In haijakamilika kwenye Firebase. Ongeza SHA-1/SHA-256 kwenye Android app ya Firebase, pakua google-services.json mpya, kisha jaribu tena.';
    }
    if (e.code == 'sign_in_failed') {
      return 'Google Sign-In imefeli: ${e.message ?? e.code}';
    }
    return 'Google Sign-In imefeli (${e.code}). ${e.message ?? 'Jaribu tena.'}';
  }
}

// ─── RESULT WRAPPER ──────────────────────────────────────────────────────────

class AuthResult {
  final bool success;
  final String message;
  final bool requiresVerification;

  AuthResult({
    required this.success,
    required this.message,
    this.requiresVerification = false,
  });
}
