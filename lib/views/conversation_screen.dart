import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatroom/Enum/message_enum.dart';
import 'package:chatroom/Utils/utils.dart';
import 'package:chatroom/services/common_firebase_storage_repository.dart';
import 'package:chatroom/widgets/document_view.dart';
import 'package:chatroom/widgets/full_image_view.dart';
import 'package:chatroom/widgets/vedio_player_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../helper/constants.dart';
import '../services/database.dart';
import '../widgets/widget.dart';

class ConversationScreen extends StatefulWidget {
  //ConversationScreen({Key? key}) : super(key: key);
  final String ChatRoomId;
  ConversationScreen(this.ChatRoomId);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  checkallpermission_opencamera() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.camera]!.isGranted) {
      if (statuses[Permission.microphone]!.isGranted) {
        openCamera();
      } else {
        showToast(
            "Camera needs to access your microphone, please provide permission",
            position: ToastPosition.bottom);
      }
    } else {
      showToast("Provide Camera permission to use camera.",
          position: ToastPosition.bottom);
    }
  }

  checkpermission_opencamera() async {
    var cameraStatus = await Permission.camera.status;
    var microphoneStatus = await Permission.microphone.status;

    print(cameraStatus);
    print(microphoneStatus);
    //cameraStatus.isGranted == has access to application
    //cameraStatus.isDenied == does not have access to application, you can request again for the permission.
    //cameraStatus.isPermanentlyDenied == does not have access to application, you cannot request again for the permission.
    //cameraStatus.isRestricted == because of security/parental control you cannot use this permission.
    //cameraStatus.isUndetermined == permission has not asked before.

    if (!cameraStatus.isGranted) await Permission.camera.request();

    if (!microphoneStatus.isGranted) await Permission.microphone.request();

    if (await Permission.camera.isGranted) {
      if (await Permission.microphone.isGranted) {
        openCamera();
      } else {
        showToast(
            "Camera needs to access your microphone, please provide permission",
            position: ToastPosition.bottom);
      }
    } else {
      showToast("Provide Camera permission to use camera.",
          position: ToastPosition.bottom);
    }
  }

  Stream<QuerySnapshot>? chatMessagesStream;
  //TextEditingController messageEditingController = new TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageController = new TextEditingController();

  Widget chatMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: chatMessagesStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      //var message;

                      return MessageTile(
                        messageEnum: snapshot.data!.docs[index]['type'],
                        message: snapshot.data!.docs[index]['message'],
                        sendByMe: Constants.myName ==
                            snapshot.data!.docs[index]["sendBy"],
                      );
                    }),
              )
            : Container();
      },
    );
  }

  sendFileMessage({
    required File file,
    required MessageEnum messageEnum,
  }) async {
    try {
      var time = Timestamp.now();
      var messageId = Uuid().v1();
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child("chats//${Constants.myName}${messageEnum.type}/$messageId")
          .putFile(file);
      TaskSnapshot snap = await uploadTask;
      String imageUrl = await snap.ref.getDownloadURL();
      // String imageUrl =
      // await ref!
      //     .read(commonFirebaseStorageRepositoryProvider)
      //     .storeFileToFirebase("chats/${messageEnum.type}/$time", file);
      // String contactMsg;
      // switch (messageEnum) {
      //   case MessageEnum.image:
      //     contactMsg = '📷 Photo';
      //     break;
      //   case MessageEnum.video:
      //     contactMsg = '📸 Video';
      //     break;
      //   case MessageEnum.audio:
      //     contactMsg = '🎵 Audio';
      //     break;
      //   case MessageEnum.doc:
      //     contactMsg = 'Doc';
      //     break;
      //   default:
      //     contactMsg = 'Doc';
      Map<String, dynamic> chatMessageMap = {
        "message": imageUrl,
        "sendBy": Constants.myName,
        "type": messageEnum.type,
        "time": FieldValue.serverTimestamp(),
      };
      await databaseMethods.addConversationMessages(
          widget.ChatRoomId, chatMessageMap);

      setState(() {
        messageController.text = "";
      });
      //    }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sendBy": Constants.myName,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      databaseMethods.addConversationMessages(
          widget.ChatRoomId, chatMessageMap);

      setState(() {
        messageController.text = "";
      });
    }
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(
        file: image,
        messageEnum: MessageEnum.image,
      );
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(
        file: video,
        messageEnum: MessageEnum.video,
      );
    }
  }

  void selectDoc() async {
    File? doc = await pickDocumentFromGallery(context);
    if (doc != null) {
      sendFileMessage(
        file: doc,
        messageEnum: MessageEnum.doc,
      );
    }
  }

  @override
  void initState() {
    databaseMethods.getConversationMessages(widget.ChatRoomId).then((val) {
      setState(() {
        chatMessagesStream = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    void showMore() {
      showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AttachWidget(
                      color: Colors.indigo,
                      size: size,
                      icon: Icons.image,
                      onTap: () {
                        selectImage();
                        Navigator.pop(context);
                      },
                      title: "Image",
                    ),
                    AttachWidget(
                      color: Colors.green,
                      size: size,
                      icon: Icons.video_camera_back,
                      onTap: () {
                        selectVideo();
                        Navigator.pop(context);
                      },
                      title: "Video",
                    ),
                    AttachWidget(
                      color: Colors.teal,
                      size: size,
                      icon: CupertinoIcons.doc,
                      onTap: () {
                        selectDoc();
                        Navigator.pop(context);
                      },
                      title: "Documents",
                    ),
                  ],
                ),
              ),
            );
          });
    }

    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: Color(0x54FFFFFF),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        style: simpleTextStyle(),
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  showMore();
                                  // checkallpermission_opencamera();
                                },
                                icon: Icon(Icons.attach_file)),
                            hintText: "Type a message...",
                            hintStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [
                                    Color(0x36FFFFFF),
                                    Color(0x0FFFFFFF)
                                  ],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight),
                              borderRadius: BorderRadius.circular(40)),
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            "assets/images/send.png",
                            height: 25,
                            width: 25,
                          )),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showToast(String s, {required position}) {}

  void openCamera() {}
}

class AttachWidget extends StatelessWidget {
  const AttachWidget({
    Key? key,
    required this.size,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  final Size size;
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircleAvatar(
          backgroundColor: color,
          radius: size.height * 0.04,
          child: IconButton(
              onPressed: onTap,
              icon: Icon(
                icon,
                size: size.height * 0.04,
              )),
        ),
        SizedBox(
          height: size.height * 0.02,
        ),
        Text(
          title,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}

class ToastPosition {
  static var bottom;
}

class MessageTile extends StatelessWidget {
  final String? message;
  final bool? sendByMe;
  final String messageEnum;
  MessageTile(
      {@required this.message,
      @required this.sendByMe,
      required this.messageEnum});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: sendByMe as bool ? 0 : 24,
          right: sendByMe as bool ? 24 : 0),
      alignment:
          sendByMe as bool ? Alignment.centerRight : Alignment.centerLeft,
      child: messageEnum == "text"
          ? Container(
              margin: sendByMe as bool
                  ? EdgeInsets.only(left: 30)
                  : EdgeInsets.only(right: 30),
              padding:
                  EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
              decoration: BoxDecoration(
                  borderRadius: sendByMe as bool
                      ? BorderRadius.only(
                          topLeft: Radius.circular(23),
                          topRight: Radius.circular(23),
                          bottomLeft: Radius.circular(23))
                      : BorderRadius.only(
                          topLeft: Radius.circular(23),
                          topRight: Radius.circular(23),
                          bottomRight: Radius.circular(23)),
                  gradient: LinearGradient(
                    colors: sendByMe as bool
                        ? [const Color(0xff357cdc), const Color(0xff2A75BC)]
                        : [const Color(0x1AFFFFFF), const Color(0x1AFFFFFF)],
                  )),
              child: Text(message!,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w300)),
            )
          : messageEnum == "video"
              ? SizedBox(
                  height: 200,
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: VideoPlayerItem(
                      videoUrl: message!,
                    ),
                  ),
                )
              : messageEnum == "doc"
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (_) =>
                                  PDFViewerCachedFromUrl(url: message!),
                            ));
                      },
                      child: Container(
                        height: 70,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          SizedBox(
                            width: 20,
                          ),
                          Icon(CupertinoIcons.doc),
                          Text("Document")
                        ]),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                FullImageViewScreen(image: message!)));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child:
                            CachedNetworkImage(height: 200, imageUrl: message!),
                      )),
    );
  }
}
