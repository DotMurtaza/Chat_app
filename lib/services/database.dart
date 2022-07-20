import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  get onError => null;

  getUserByUsername(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("name", isEqualTo: username)
        .get(); //il fnctionne sans catch
  }

  getUserByUserEmail(String userEmail) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: userEmail)
        .get(); //il fnctionne sans catch
  }

  uploadUserInfo(userMap) {
    FirebaseFirestore.instance.collection("users").add(userMap).catchError((e) {
      print(e.toString());
    }); //il fnctionne sans catch
  }

  creatChatRoom(String chatroomId, ChatRoomMap) {
    // FirebaseFirestore.instance.collection("ChatRoom").doc(chatroomId).set(ChatRoomMap).catchError((e) {
    //     print(e.toString());});

    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatroomId)
        .get()
        .then((onValue) {
      onValue.exists
          ? print(chatroomId +
              " =chatroomId existttttttttttttttttttttttttttttttttttt")
          // FirebaseFirestore.instance.collection("ChatRoom").doc(chatroomId).update(ChatRoomMap).catchError((e) {
          //      print(e.toString());}) // exists
          : {
              FirebaseFirestore.instance
                  .collection("ChatRoom")
                  .doc(chatroomId)
                  .set(ChatRoomMap)
                  .catchError((e) {
                print(e.toString());
              }),
              print(chatroomId +
                  " =chatroomId   not__existttttttttttttttttttttttttttttttt")
            }; // does not exist ;
    });
  }

  addConversationMessages(String chatRoomId, messageMap) async {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(messageMap);
  }

  getConversationMessages(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy('time')
        .snapshots();
  }

  getChatRooms(String userName) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: userName)
        .snapshots();
  }
}
