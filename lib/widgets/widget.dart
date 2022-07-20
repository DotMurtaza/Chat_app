import 'package:flutter/material.dart';

PreferredSizeWidget appBarMain(BuildContext context){
  return AppBar(
    title: Image.asset("assets/images/logo.png", height: 45,),
  );
}

InputDecoration textFieldInputDecoration( Size size ,String hintext , IconData icon ){
  return InputDecoration(
                    hintText: hintext,
                    prefixIcon: Icon(icon),
                    hintStyle: TextStyle(
                      color: Colors.white30,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                      BorderSide(
                          color: Colors.white30
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(
                          color: Colors.white
                      ),
                    ),
                  );
}

TextStyle simpleTextStyle(){
  return TextStyle(
    color: Colors.white,
    fontSize: 16,
  );
}

TextStyle mediumTextStyle(){
  return TextStyle(
    color: Colors.white,
    fontSize: 17,
  );
}