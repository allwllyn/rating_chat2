import 'package:rating_chat2/models/user.dart';
import 'package:rating_chat2/services/auth_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'register.dart';
import 'home.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInPage extends StatefulWidget {
  @override
  State<SignInPage> createState() => _SignIn();
}

class _SignIn extends State<SignInPage> {
  // const SignInPage({ Key? key }) : super(key: key);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  //final GoogleSignIn googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  @override
  void initState() {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    authBloc.currentUser.listen((fbUser) async {
      if (fbUser != null) {
        User? user = fbUser;
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        UserModel userModel = UserModel.fromJson(userData);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HomePage(userModel)));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
        body: _loading
            ? LoadingPage()
            : Center(
                child: Form(
                    key: _formKey,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Rating Chat",
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Username or Email',
                                ),
                                controller: _email,
                                validator: (String? text) {
                                  if (text == null || text.isEmpty) {
                                    return "your email can't be empty";
                                  } else if (!text.contains('@')) {
                                    return "please enter valid email";
                                  }
                                })),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Password',
                                ),
                                controller: _password,
                                validator: (String? text) {
                                  if (text == null || text.length < 6) {
                                    return "Your password cant be empty";
                                  }
                                  return null;
                                })),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 90.0, vertical: 2.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              onPrimary: Colors.white,
                              minimumSize: Size(double.infinity, 50),
                            ),
                            onPressed: () {
                              setState(() {
                                _loading = true;
                                logIn(context);
                              });
                            },
                            child: const Text("Log In"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 90.0, vertical: 2.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              onPrimary: Colors.white,
                              minimumSize: Size(double.infinity, 50),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => RegisterPage()));
                            },
                            child: const Text("Register"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 90.0, vertical: 2.0),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              onPrimary: Colors.white,
                              minimumSize: Size(double.infinity, 50),
                            ),
                            icon: FaIcon(FontAwesomeIcons.google),
                            label: Text('Sign in with Google'),
                            onPressed: () => authBloc.loginGoogle(),

                            //child: const Text("Log in with Google"),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text("Forgot Password"),
                        ),
                      ],
                    )))));
  }

  void logIn(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: _email.text, password: _password.text);
        User? user = _auth.currentUser;
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        UserModel userModel = UserModel.fromJson(userData);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HomePage(userModel)));
      } on FirebaseAuthException catch (e) {
        if (e.code == "wrong-password" || e.code == "no-email") {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Incorrect email/password")));
        } else {
          setState(() {
            _loading = false;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
