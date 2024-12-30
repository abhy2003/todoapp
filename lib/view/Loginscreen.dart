import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todoapp/view/Homescreen.dart';
import 'package:todoapp/view/Signupscreen.dart';

import '../controller/authcontroller.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final AuthController authController = Get.put(AuthController());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "Login",
          style: GoogleFonts.poppins(),
        ),
      ),
      body:Form(
    key: _formKey,
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                  return 'enter an email ';
                }
                final emailRegex =
                RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'enter a valid email format';
                }
                return null;
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
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
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$');

                if (!passwordRegex.hasMatch(value)) {
                  return 'Password must be at least 6 characters long, \ncontain an uppercase letter, a number, and a special character';
                }
                return null;
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  String email = _emailController.text.trim();
                  if (email.isNotEmpty) {
                    authController.resetPassword(email);
                  } else {
                    Get.snackbar('Error', 'Please enter your email to reset password.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white);
                  }
                },
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.poppins(color: Colors.blue),
                ),
              ),),
            ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                String email = _emailController.text;
                String password = _passwordController.text;

                try {
                  final userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(email: email, password: password);

                  if (userCredential.user?.emailVerified ?? false) {
                    Get.offAll(() => Homescreen());
                  } else {
                    Get.snackbar('Error', 'Please check your gmail and verify it.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white);
                  }
                } on FirebaseAuthException catch (e) {
                  String errorMessage =
                      e.message ?? 'An unexpected error occurred';
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
              'Login',
              style: GoogleFonts.poppins(fontSize: 15.0, color: Colors.white),
            ),
          ),
          SizedBox(height: 3),
          TextButton(
            onPressed: () {
              Get.off(Signupscreen());
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(60.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.0),
            ),
            child: Text(
              'Signup',
              style: GoogleFonts.poppins(fontSize: 15.0, color: Colors.black),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
