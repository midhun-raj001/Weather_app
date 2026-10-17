import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> getUserProfile() async {
    User? user = _auth.currentUser;
    // On web, currentUser might be null for a few milliseconds after reload.
    if (user == null) {
      try {
        user = await _auth.authStateChanges().first;
      } catch (_) {}
    }
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        // Create initial profile
        final newUser = UserModel(uid: user.uid);
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
      return UserModel.fromDocument(doc);
    } catch (e) {
      return null;
    }
  }
}
