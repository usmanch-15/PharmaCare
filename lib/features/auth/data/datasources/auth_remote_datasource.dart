import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(
      String email, String password, String name, String role);
  Future<void> logout();
  Future<Map<String, dynamic>?> getCurrentUser();
  Stream<Map<String, dynamic>?> watchAuthState();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._auth, this._fs);
  final FirebaseAuth     _auth;
  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> get _users =>
      _fs.collection('users');

  @override
  Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return await _fetchUserData(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw ServerException(_authMessage(e.code));
    }
  }

  @override
  Future<Map<String, dynamic>> register(
      String email, String password, String name, String role) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final uid = cred.user!.uid;
      await cred.user!.updateDisplayName(name);

      final userData = {
        'uid':       uid,
        'name':      name,
        'email':     email,
        'role':      role,
        'isActive':  true,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _users.doc(uid).set(userData);
      return {...userData, 'uid': uid};
    } on FirebaseAuthException catch (e) {
      throw ServerException(_authMessage(e.code));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await _fetchUserData(user.uid);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchAuthState() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        return await _fetchUserData(user.uid);
      } catch (_) {
        return null;
      }
    });
  }

  Future<Map<String, dynamic>> _fetchUserData(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) throw const ServerException('User profile not found.');
    return {'uid': uid, ...doc.data()!};
  }

  String _authMessage(String code) => switch (code) {
        'user-not-found'       => 'No account found with this email.',
        'wrong-password'       => 'Incorrect password.',
        'invalid-email'        => 'Invalid email address.',
        'email-already-in-use' => 'An account already exists with this email.',
        'weak-password'        => 'Password must be at least 6 characters.',
        'user-disabled'        => 'This account has been disabled.',
        'too-many-requests'    => 'Too many attempts. Please try again later.',
        _                      => 'Authentication failed. Please try again.',
      };
}