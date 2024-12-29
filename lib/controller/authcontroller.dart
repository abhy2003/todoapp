import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/authmodel.dart';

class AuthController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

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
        Get.offAllNamed('/home');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Something went wrong");
    }
  }

  Stream<Map<String, String>> getUserInfoStream() {
    return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          String name = userDoc['name'] ?? 'No name available';
          String email = userDoc['email'] ?? 'No email available';
          print('User Info: Name: $name, Email: $email');

          return {'name': name, 'email': email};
        }
      }
      return {'name': 'No name', 'email': 'No email'};
    });
  }

  Widget buildAuthStateStream() {
    return StreamBuilder<User?>(
      stream: _firebaseAuth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Something went wrong.'));
        } else if (snapshot.hasData) {
          User? user = snapshot.data;
          return StreamBuilder<Map<String, String>>(
            stream: getUserInfoStream(),
            builder: (context, userInfoSnapshot) {
              if (userInfoSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (userInfoSnapshot.hasError) {
                return Center(child: Text('Error loading user data.'));
              } else if (userInfoSnapshot.hasData) {
                var userData = userInfoSnapshot.data;
                return Center(child: Text('Welcome, ${userData?['name']} (${userData?['email']})'));
              } else {
                return Center(child: Text('User info not available.'));
              }
            },
          );
        } else {
          return Center(
            child: ElevatedButton(
              onPressed: signOut,
              child: Text('Logout'),
            ),
          );
        }
      },
    );
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
