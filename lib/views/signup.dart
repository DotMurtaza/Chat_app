import 'package:flutter/material.dart';
import '../helper/helperfunctions.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../widgets/widget.dart';
import 'chatRoomsScreen.dart';


class SignUp extends StatefulWidget {
  final Function toggleView;
  SignUp(this.toggleView);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool isLoading=false;
 AuthMethods authMethods =new AuthMethods();
 DatabaseMethods databaseMethods=new DatabaseMethods();

  final formKey=GlobalKey<FormState>();
  TextEditingController userNameTextEditingController=new TextEditingController();
  TextEditingController emailTextEditingController=new TextEditingController();
  TextEditingController passwordTextEditingController=new TextEditingController();

  signMeUp(){
    if(formKey.currentState!.validate()){
      Map<String,String> userInfoMap = {
                "name" : userNameTextEditingController.text,
                "email" : emailTextEditingController.text
              };

              HelperFunctions.saveUserEmailSharedPreference(emailTextEditingController.text);
              HelperFunctions.saveUserNameSharedPreference(userNameTextEditingController.text);

      setState(() {
        isLoading=true;
      });
      
      authMethods.signUpwithEmailAndPassword(emailTextEditingController.text, 
      passwordTextEditingController.text).then((val){
          //print("$val.uid");

          

          databaseMethods.uploadUserInfo(userInfoMap);
          HelperFunctions.saveUserLoggedInSharedPreference(true);
          Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => ChatRoom()
              ));
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
        body: isLoading ? Container(
          child: Center(
              child: CircularProgressIndicator()),
        ) :SingleChildScrollView(
          child: Container(
          height: MediaQuery
              .of(context)
              .size
              .height - 90,
          alignment: Alignment.bottomCenter,
          child: Container(
            
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [


              Form(
                key: formKey,
                child: Column(
                  children: [


                    Container(

                      height: size.height / 4,
                      child: Text(
                        "CREATE AN ACCOUNT" ,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,

                        ),
                      ),
                    ),





                    TextFormField(
                      validator: (val){
                        return val!.isEmpty || val.length <2 ? "Please provide UserName!":
                        null;
                      },
                  controller: userNameTextEditingController,
                  style: simpleTextStyle(),
                  decoration:
                  textFieldInputDecoration(size,"Enter username", Icons.person_add  ),
                ),
                TextFormField(
                  validator: (val){
                      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val as String) ?
                          null : "Enter correct email";
                    },
                  controller: emailTextEditingController,
                  style: simpleTextStyle(),
                  decoration: textFieldInputDecoration(size , "Enter email", Icons.account_box),
                ),
                TextFormField(
                  obscureText: true,
                  validator:  (val){
                      return val!.length < 6
                          ? "Enter Password +6 characters"
                          : null;
                    },
                  controller: passwordTextEditingController,
                  style: simpleTextStyle(),
                  decoration: textFieldInputDecoration(size,"Enter new password", Icons.lock),
                ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),

              SizedBox(height: 8,),
              GestureDetector(
                onTap: (){
                  signMeUp();
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      const Color(0xFF7D7E7D),
                      const Color(0xFF7D7E7D),
              
                    ]),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Sign Up",
                    style: mediumTextStyle(),
                  ),
                ),
              ),
              SizedBox(height: 16,),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Sign Up With Google",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 17,
                  ),
                ),
              ),
              SizedBox(height: 16,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have account? ",
                    style:
                    TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      widget.toggleView();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Sign In now",
                        style:
                        TextStyle(
                        color: Colors.blueGrey,
                        decoration: TextDecoration.underline,
                        fontSize: 17,
                       ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50,),

            ],
          ),
        ),
        ),
        ));
  }
  
}