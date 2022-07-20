import 'dart:ffi';
import 'dart:io';
import 'package:chatroom/services/auth.dart';
import 'package:chatroom/views/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helper/authenticate.dart';
import '../helper/constants.dart';
import '../helper/helperfunctions.dart';
import '../services/database.dart';
import 'conversation_screen.dart';


class ChatRoom extends StatefulWidget {
  ChatRoom({Key? key}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with SingleTickerProviderStateMixin {
  late TabController _controller ;






  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods=new DatabaseMethods();

  Stream<QuerySnapshot>? chatRoomsStream;
  
  Widget? chatRoomList(){
    return StreamBuilder<QuerySnapshot>(                 //<QuerySnapshot>(
      stream: chatRoomsStream,
      builder: (context , snapshot){
        return snapshot.hasData ? ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context , index){
            return ChatRoomsTile(
              //userName: snapshot.doc[index]['chatroomId'],
              userName: snapshot.data!.docs[index]['chatroomId']
              .toString().replaceAll("_", "").replaceAll(Constants.myName, ""),
              chatroomId: snapshot.data!.docs[index]['chatroomId']);
          }): Container();
      },
      );
  }
    @override
  void initState() {

    /// todo implement initstate
    getUserInfo();
    super.initState();
    _controller = TabController(length: 3, vsync: this,initialIndex: 1) ;
  }

  getUserInfo() async {
    await HelperFunctions.getUserNameInSharedPreference()
    .then(( result){
setState(() {
     Constants.myName = result as String;
    });
});
    databaseMethods.getChatRooms(Constants.myName).then(
      (value){
          setState(() {
            chatRoomsStream=value;
          });
      });
      setState(() {
        
      });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("assets/images/logo.png", height: 50,),
        actions: [
          GestureDetector(
            onTap: () {
              authMethods.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Authenticate()));
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.logout)),
          )
        ],







        bottom: TabBar(
          controller: _controller,
          tabs: [
            Tab(icon:  Icon(Icons.camera_alt),),
            Tab( text: "CHATS",),
            Tab( text: "CALLS",),
          ],
        ),






      ),


      body
          : Container(
        child: chatRoomList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchScrren()));
        },
      ),
    );
  }
}



class ChatRoomsTile extends StatelessWidget {
  final String? userName;
  final String? chatroomId;
  ChatRoomsTile({this.userName,@required this.chatroomId});

  @override
  Widget build(BuildContext context) {
     return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ConversationScreen(
          chatroomId as String ,
          )
        ));
      },
      child: Container(
        color: Colors.black26,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: Colors.blueAccent ,                                             //  CustomTheme.colorAccent,
                  borderRadius: BorderRadius.circular(30)),
              child: Text(userName!.substring(0, 1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w300)),
            ),
            SizedBox(
              width: 12,
            ),
            Text(userName as String,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300))
         ],
        ),
      ),
    );
  }
}




