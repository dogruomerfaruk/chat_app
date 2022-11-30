import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/widgets/appbar.dart';

import '../helpers/helpers.dart';

class ChatPage extends StatefulWidget {
  ChatPage(
      {super.key,
      required this.userName,
      required this.id,
      required this.badge,
      required this.to});
  final String userName;
  final String id;
  final String to;
  final String badge;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ScrollController listScrollController = ScrollController();
  final messageController = TextEditingController();

  CollectionReference chat = FirebaseFirestore.instance.collection('chats');

  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    scrolltobot();
  }

  void sendMessage() {
    Map<String, dynamic> toadd = {
      'message': messageController.text,
      'sender': widget.userName,
      'timestamp': DateTime.now(),
    };
    chat.doc(widget.id).update({
      "oldMessages": FieldValue.arrayUnion([toadd])
    });
    chat.doc(widget.id).update({
      "recentMessages": FieldValue.arrayUnion([toadd]),
      "recentMessageFrom": widget.userName
    });
    messageController.clear();
    scrolltobot();
  }

  void scrolltobot() {
    if (listScrollController.hasClients) {
      final position = listScrollController.position.maxScrollExtent;
      listScrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  late Stream<QuerySnapshot>? chats = FirebaseFirestore.instance
      .collection('chats')
      .where('id', isEqualTo: widget.id)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarChat(),
      body: Stack(
        children: <Widget>[
          // Container(
          //     alignment: Alignment.bottomCenter,
          //     width: MediaQuery.of(context).size.width,
          //     child: Container(
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          //         width: MediaQuery.of(context).size.width,
          //         child: Header(
          //             name: widget.userName,
          //             badge: widget.badge,
          //             to: widget.to))),
          StreamBuilder<QuerySnapshot>(
              stream: chats,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  //print("errorror");
                  return const Text("errrrr");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  //print("waiting");
                  return const Text("connecting");
                } else {
                  scrolltobot();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                    child: ListView.builder(
                      controller: listScrollController,
                      itemCount: snapshot.data.docs[0]['oldMessages'].length,
                      itemBuilder: (context, index) {
                        return MessageBox(
                          message: snapshot.data.docs[0]['oldMessages'][index]
                              ['message'], //messages[index]['message'],
                          sender: snapshot.data.docs[0]['oldMessages'][index]
                              ['sender'], //messages[index]['sender'],
                          sentByMe: snapshot.data.docs[0]['oldMessages'][index]
                                  ['sender'] ==
                              widget.userName,
                          timestamp: snapshot.data.docs[0]['oldMessages'][index]
                              ['timestamp'],
                        ); //messages[index]['sentbyme']);
                      },
                    ),
                  );
                }
              }),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Send a message...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: InputBorder.none,
                  ),
                )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                        child: Icon(
                      Icons.send,
                      color: Colors.white,
                    )),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }
}

class MessageBox extends StatefulWidget {
  const MessageBox({
    super.key,
    required this.message,
    required this.sender,
    required this.sentByMe,
    required this.timestamp,
  });

  final String message;
  final String sender;
  final bool sentByMe;
  final Timestamp timestamp;
  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  @override
  Widget build(BuildContext context) {
    DateTime dt = widget.timestamp.toDate();
    final d24 = int.parse(dt.hour.toString()).toString() +
        ":" +
        int.parse(dt.minute.toString()).toString();
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
          crossAxisAlignment: widget.sentByMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(
                maxWidth: 240,
              ),
              margin: widget.sentByMe
                  ? const EdgeInsets.only(left: 30)
                  : const EdgeInsets.only(right: 30),
              padding: const EdgeInsets.only(
                  top: 17, bottom: 17, left: 20, right: 20),
              decoration: BoxDecoration(
                  borderRadius: widget.sentByMe
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                  color: widget.sentByMe
                      ? const Color(0xFFE7F1EE)
                      : Colors.grey[700]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.message,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF1A2321)))
                ],
              ),
            ),
            Text(d24,
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9DA1A0)))
          ]),
    );
  }
}

class Header extends StatefulWidget {
  const Header({
    super.key,
    required this.name,
    required this.badge,
    required this.to,
  });

  final String name;
  final String to;
  final String badge;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final helper = Helper();
  String initials = '';

  @override
  void initState() {
    super.initState();
    initials = helper.getInitials(widget.to);
  }

  late Stream<QuerySnapshot>? users = FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: widget.to)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: users,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //print("waiting");
            return const Text("connecting");
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(25.0, 0.0, 0.0, 0.0),
                        child: Stack(children: <Widget>[
                          CircleAvatar(maxRadius: 27, child: Text(initials)),
                          (snapshot.data.docs[0]['status'] == "online")
                              ? Positioned(
                                  bottom: 0,
                                  right: 10,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle),
                                  ),
                                )
                              : Container(),
                        ])),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0)),
                          Row(children: [
                            Text(
                              widget.to,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0,
                              ),
                            ),
                            const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0)),
                            Container(
                              decoration: const BoxDecoration(
                                  color: Color(0xFFD8FDDB),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  )),
                              padding: const EdgeInsets.only(
                                  top: 1, bottom: 1, left: 15, right: 15),
                              child: Text(
                                widget.badge,
                                style: const TextStyle(
                                  color: Color(0xFF029E48),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.0,
                                ),
                              ),
                            )
                          ]),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.0)),
                          Text(
                            snapshot.data.docs[0]['status'] == "online"
                                ? "Cevrimici"
                                : "Cevrimdisi",
                            style: const TextStyle(fontSize: 12.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
