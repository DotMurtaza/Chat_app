import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../helper/constants.dart';
import '../helper/helperfunctions.dart';
import '../services/database.dart';
import '../widgets/widget.dart';
import 'conversation_screen.dart';

class SearchScrren extends StatefulWidget {
  @override
  _SearchScrrenState createState() => _SearchScrrenState();
}
String? _myName;
class _SearchScrrenState extends State<SearchScrren> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchEditingController = new TextEditingController();

  QuerySnapshot? searchSnapshot;


  initiateSearch() {
    //FirebaseFirestore.instance.collection('users').get().then((value){
    databaseMethods.getUserByUsername(searchEditingController.text)
        .then((val) {
      setState(() {
        searchSnapshot = val;
      });
    });
  }
  ////// create chatRoom send user to conversation screen pushreplacement
  creatChatroomsendAndStartConversition({String? userName}) {
    print("${Constants.myName}");
    if(userName!=Constants.myName){
      String chatRoomId = getChatRoomId(userName as String,Constants.myName );
      print(chatRoomId+'   =chatRoomId           aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
      List<String> users = [userName as String, Constants.myName];

      Map<String, dynamic> chatRoomMap = {
        "users": users,                                   // il faut verifier l'order user et chatroomId
        "chatroomId": chatRoomId,
      };

      DatabaseMethods().creatChatRoom(chatRoomId, chatRoomMap);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConversationScreen(
              chatRoomId
          ),
        ),
      );
    } else{
      print("you can't send to your self");
    }
  }

  Widget searchList() {



    return searchSnapshot != null
        ? ListView.builder(
        itemCount: searchSnapshot!.docs.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return SearchTile (
              userName: searchSnapshot!.docs[index]
              ["name"], ////.............
              userEmail: searchSnapshot!.docs[index]
              ["email"] ,////.............
          );

        })
        : Container();
  }

  Widget SearchTile({String? userName,String? userEmail}){
    // late final String? userName;
    // late final String? userEmail;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName as String,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  userEmail as String,
                  style:  TextStyle(
                    color: Colors.white54,
                    fontSize: 17,

                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              creatChatroomsendAndStartConversition(userName: userName);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("Message"),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async{
    _myName= await HelperFunctions.getUserNameInSharedPreference();
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: Color(0x54FFFFFF),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchEditingController,
                        style: simpleTextStyle(),
                        decoration: InputDecoration(
                            hintText: "search username ...",
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        initiateSearch();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0x36FFFFFF),
                                    const Color(0x0FFFFFFF)
                                  ],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight),
                              borderRadius: BorderRadius.circular(40)),
                          padding: EdgeInsets.all(12),
                          child: Image.asset(
                            "assets/images/search_white.png",
                            height: 25,
                            width: 25,
                          )),
                    )
                  ],
                ),
              ),
              searchList(),
              //userList()
            ],
          ),
        ),
      ),

    );
  }
}



getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
