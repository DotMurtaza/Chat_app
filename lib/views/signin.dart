
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../helper/helperfunctions.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../widgets/widget.dart';
import 'chatRoomsScreen.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn(this.toggleView);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final formKey = GlobalKey<FormState>();
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();
  bool isLoading = false;
  QuerySnapshot? userInfoSnapshot;

  _signIn() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      await authMethods.signInWithEmailAndPassword(
          emailTextEditingController.text,
          passwordTextEditingController.text)!.then((result) async {
        if (result != null) {
          userInfoSnapshot =
          await DatabaseMethods().getUserByUserEmail(
              emailTextEditingController.text);
          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(
              userInfoSnapshot!.docs[0]["name"]);
          HelperFunctions.saveUserEmailSharedPreference(
              userInfoSnapshot!.docs[0]["email"]);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ChatRoom()));
        } else {
          setState(() {
            isLoading = false;
            //show snackbar
          });
        }
      });
    }
  }

  signIn() async {
    if (formKey.currentState!.validate()) {
      HelperFunctions.saveUserEmailSharedPreference(
          emailTextEditingController.text);
      databaseMethods.getUserByUserEmail(emailTextEditingController.text)

          .then((val) {
        userInfoSnapshot = val;
        HelperFunctions.saveUserNameSharedPreference(
            userInfoSnapshot!.docs[0]["name"]);
      });

      setState(() {
        isLoading = true;
      });

      await authMethods.signInWithEmailAndPassword(
          emailTextEditingController.text,
          passwordTextEditingController.text)!.then((result) async {
        if (result != null) {
          HelperFunctions.saveUserLoggedInSharedPreference(true);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ChatRoom()));
          userInfoSnapshot = await DatabaseMethods()
              .getUserByUsername(emailTextEditingController.text);
        } else {
          setState(() {
            isLoading = false;
            //show snackbar
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
        appBar: appBarMain(context),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery
                .of(context).size.height - 45,
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [






                  Form(
                    key: formKey,
                    child: Column(
                      children: [

                        Container(
                          width: size.width / 1,
                          height: size.height / 2.5,
                          child: Text(
                            "Welcome to the AppChat" ,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,

                            ),
                          ),
                        ),

                        Container(
                          width: size.width / 1,

                          child: Text(
                            "Sign In to continue !" ,
                            style: TextStyle(
                              color: Colors.white60 ,
                              fontSize: 23,
                              fontWeight: FontWeight.w400,

                            ),
                          ),
                        ),


                        SizedBox(
                          height: size.height / 100,
                        ),





                        TextFormField(
                          validator: (val) {
                            return RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(val as String)
                                ? null
                                : "Check that the email is correct";
                          } ,
                          controller: emailTextEditingController,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration(size, "Email", Icons.account_box),

                        ),
                        TextFormField(
                          obscureText: true,
                          validator: (val) {
                            return val!.length < 6
                                ? "Check that password is correct"
                                : null;
                          },
                          controller: passwordTextEditingController,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration(size,"Password", Icons.lock),
                        ),
                      ],
                    ),

                  ),
                  SizedBox(
                    height: 8,
                  ),

                  SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: () {
                      _signIn();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0xFF7D7E7D),
                          const Color(0xFF7D7E7D),
                        ]),

                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "Sign In",
                        style: mediumTextStyle(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "Sign In With Google",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have account? ",
                        style:
                        TextStyle(
                          color: Colors.white,
                          fontSize: 17,

                        ),

                      ),
                      GestureDetector(
                        onTap: () {
                          widget.toggleView();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "Register now",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              decoration: TextDecoration.underline,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),

          ),

        ));


  }



}



