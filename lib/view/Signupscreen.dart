import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todoapp/view/Loginscreen.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

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
      body:Form(
        key: _formKey,
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
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
                      return 'first letter must be capital';
                    }
                    return null;
                  }

              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
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
                    return 'Password must be at least 6 characters long, \ncontain an uppercase letter, a number, and a special character (#, *)';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  print('Form is valid. Logging in...');
                  Get.to(()=>Loginscreen());
                } else {
                  print('Form is invalid. Please correct the errors.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              child: Text(
                'Signup',
                style: GoogleFonts.poppins(fontSize: 15.0, color: Colors.black),
              ),
            ),
            SizedBox(height: 3),
            TextButton(
              onPressed: () {},
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
