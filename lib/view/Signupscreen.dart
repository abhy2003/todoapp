import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todoapp/view/Loginscreen.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final GetStorage _storage = GetStorage();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _namecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "Signup",
          style: GoogleFonts.poppins(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                controller: _namecontroller,
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: GoogleFonts.poppins(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  final nameRegex = RegExp(r'^[A-Z][a-zA-Z]*$');
                  if (!nameRegex.hasMatch(value)) {
                    return 'First letter must be capital';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: GoogleFonts.poppins(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter an email';
                  }
                  final emailRegex =
                  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Enter a valid email format';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: GoogleFonts.poppins(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  final passwordRegex =
                  RegExp(r'^(?=.*[A-Z])(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$');
                  if (!passwordRegex.hasMatch(value)) {
                    return 'Password must be at least 8 characters long, contain an uppercase letter, a number, and a special character (#, *)';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  print('Form is valid. Signing up...');

                  String email = _emailController.text;
                  String password = _passwordController.text;
                  String name = _namecontroller.text;

                  try {
                    final signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
                    if (signInMethods.isNotEmpty) {
                      Get.snackbar('Error', 'This email is already in use.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                      return;
                    }

                    final userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    final user = userCredential.user;

                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .set({
                        'email': email,
                        'name': name,
                        'userId': user.uid,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      await user.sendEmailVerification();

                      _storage.write('isLoggedIn', true);
                      _storage.write('userId', user.uid);

                      Get.to(() => Loginscreen());

                      Get.snackbar('Success', 'User created successfully. Please verify your email.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white);
                    }
                  } on FirebaseAuthException catch (e) {

                    String errorMessage = e.message ?? 'An unexpected error occurred';
                    Get.snackbar('Error', errorMessage,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white);
                  }
                } else {
                  print('Form is invalid. Please correct the errors.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              child: Text(
                'Signup',
                style: GoogleFonts.poppins(fontSize: 15.0, color: Colors.white),
              ),
            ),
            SizedBox(height: 3),
            TextButton(
              onPressed: () {
                Get.off(Loginscreen());
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              child: Text(
                'Login',
                style: GoogleFonts.poppins(fontSize: 15.0, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
