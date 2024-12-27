import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../model/authmodel.dart';

class AuthController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  Future<void> signUp(String name, String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      _showErrorMessage('Passwords do not match.');
      return;
    }

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final userModel = UserModel(
          name: name,
          email: email,
          userId: user.uid,
        );

        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
        await user.sendEmailVerification();

        _showSuccessMessage('Verification email sent. Please check your inbox.');
        Get.offAllNamed('/login');
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Store user session
        _storeSession(user.uid);
        Get.offAllNamed('/home');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _clearSession();
    Get.offAllNamed('/login');
  }

  bool isUserLoggedIn() {
    return _storage.read('isLoggedIn') ?? false;
  }

  String? getUserId() {
    return _storage.read('userId');
  }

  void _storeSession(String userId) {
    _storage.write('isLoggedIn', true);
    _storage.write('userId', userId);
  }

  void _clearSession() {
    _storage.erase();
  }

  void _handleAuthError(FirebaseAuthException e) {
    final errorMessage = _getErrorMessage(e.code);
    if (errorMessage.isNotEmpty) {
      _showErrorMessage(errorMessage);
    }
  }

  void _showErrorMessage(String message) {
    Get.snackbar('Error', message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
  }

  void _showSuccessMessage(String message) {
    Get.snackbar('Success', message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'The user has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
