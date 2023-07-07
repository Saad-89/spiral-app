import 'package:flutter/material.dart';

import '../utils/firebase_services.dart';
import 'cart_page.dart';
import 'sign-in.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  TextEditingController _passwordController =
      TextEditingController(); // Add this line

  @override
  void dispose() {
    _passwordController.dispose(); // Dispose the TextEditingController
    super.dispose();
  }

  String? firstName;
  String? lastName;
  String? email;
  String? password;

  FirebaseServices firebaseServices = FirebaseServices();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe1d5c9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_new),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            'SIGN UP',
                            style: TextStyle(
                              fontFamily: 'Karla',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              FirstNameLastName(
                                hintText: 'First Name',
                                onChanged: (value) {
                                  setState(() {
                                    firstName = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 15),
                              FirstNameLastName(
                                hintText: 'Last Name',
                                onChanged: (value) {
                                  setState(() {
                                    lastName = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your last name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                style: TextStyle(
                                  fontFamily: "Karla",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  hintText: 'Email',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Karla',
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  // Add email validation logic if needed
                                  return null;
                                },
                                onChanged: (value) {
                                  email = value;
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                obscureText: !_isPasswordVisible,
                                style: TextStyle(
                                  fontFamily: "Karla",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Karla',
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  // Add email validation logic if needed
                                  return null;
                                },
                                onChanged: (value) {
                                  password = value;
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                      ),
                                      child: TextButton(
                                        onPressed: () async {
                                          print(firstName);
                                          print(lastName);
                                          print(email);
                                          print(password);
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          await Future.delayed(
                                              Duration(seconds: 1));

                                          if (_formKey.currentState!
                                              .validate()) {
                                            // Form is valid, perform your desired action here

                                            await firebaseServices
                                                .signUpWithEmail(
                                                    email!, password!);
                                            await firebaseServices.userInfo(
                                                firstName!, lastName!, email!);
                                            Navigator.pop(context);
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                        },
                                        child: _isLoading
                                            ? CircularProgressIndicator(
                                                // color: Colors.white,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              )
                                            : Text(
                                                'CONTINUE',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Karla',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('Already have an acccount',
                                      style: TextStyle(color: Colors.black)),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  InkWell(
                                    child: Text(
                                      'Login In',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SignInPage()),
                                      );
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FirstNameLastName extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  FirstNameLastName({Key? key, this.hintText, this.validator, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      style: TextStyle(
        fontFamily: "Karla",
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Karla',
        ),
      ),
      validator: validator,
    );
  }
}
