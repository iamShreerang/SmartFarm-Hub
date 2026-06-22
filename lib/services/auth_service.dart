import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_profile.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(name);

    final profile = UserProfile(
      uid: cred.user!.uid,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection('users')
        .doc(cred.user!.uid)
        .set(profile.toFirestore());
    return profile;
  }

  Future<UserProfile?> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return getProfile(cred.user!.uid);
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> signOut() => _auth.signOut();

  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(profile.uid)
        .update(profile.toFirestore());
    return profile;
  }

  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref('profile_images/$uid.jpg');
    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();
    await _firestore
        .collection('users')
        .doc(uid)
        .update({'profileImageUrl': url});
    return url;
  }
}
