import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/widgets/appbar.dart';

import 'package:my_app/screens/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/helpers/helpers.dart';

class Messages extends StatefulWidget {
  const Messages({
    super.key,
    required this.name,
    required this.chatIDs,
  });

  final String name;
  final List chatIDs;
  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    CollectionReference chat = FirebaseFirestore.instance.collection('users');
    switch (state) {
      case AppLifecycleState.resumed:
        print('app resumed');
        chat.doc(widget.name).update({"status": "online"});
        break;
      case AppLifecycleState.inactive:
        chat.doc(widget.name).update({"status": "offline"});
        print('app inactive');
        break;
      case AppLifecycleState.paused:
        chat.doc(widget.name).update({"status": "offline"});
        print('app paused');
        break;
      case AppLifecycleState.detached:
        chat.doc(widget.name).update({"status": "offline"});
        print('app detached');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarChat(),
      body: ListMessages(name: widget.name, chatIDs: widget.chatIDs),
    );
  }
}

//========================================================================================
class ListMessages extends StatefulWidget {
  const ListMessages({
    super.key,
    required this.name,
    required this.chatIDs,
  });
  final String name;
  final List chatIDs;

  @override
  State<ListMessages> createState() => _ListMessagesState();
}

class _ListMessagesState extends State<ListMessages> {
  Stream<QuerySnapshot>? users = FirebaseFirestore.instance
      .collection('users')
      //.where('username', isEqualTo: widget.name)
      .snapshots();

  Stream<QuerySnapshot>? chats = FirebaseFirestore.instance
      .collection('chats')
      //.where('id', arrayContains: chats['chatIDs'])
      .snapshots();

  void onListItem(String id, String from, String badge, String to) {
    if (from != widget.name) {
      CollectionReference chat = FirebaseFirestore.instance.collection('chats');
      chat.doc(id).update({"recentMessageFrom": "-1"});
      chat.doc(id).update({"recentMessages": []});
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ChatPage(userName: widget.name, id: id, badge: badge, to: to)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            //print("errorror");
            return const Text("error");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            //print("waiting");
            return const Text("connecting");
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data.docs.length, // items length
              itemBuilder: (context, index) {
                return widget.chatIDs.contains(snapshot.data.docs[index]['id'])
                    ? Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              onListItem(
                                  snapshot.data.docs[index]['id'],
                                  snapshot.data.docs[index]
                                      ['recentMessageFrom'],
                                  snapshot.data.docs[index]['badge'],
                                  widget.name ==
                                          snapshot.data.docs[index]['user2']
                                      ? snapshot.data.docs[index]['user1']
                                      : snapshot.data.docs[index]['user2']);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: ListItem(
                              to: widget.name ==
                                      snapshot.data.docs[index]['user2']
                                  ? snapshot.data.docs[index]['user1']
                                  : snapshot.data.docs[index]['user2'],
                              name: widget.name,
                              oldMessage: snapshot.data.docs[index]
                                  ['oldMessages'],
                              recentMessage: snapshot.data.docs[index]
                                  ['recentMessages'],
                              recentMessageFrom: snapshot.data.docs[index]
                                  ['recentMessageFrom'],
                              badge: snapshot.data.docs[index]['badge'],
                            ),
                          ),
                          const Divider(),
                        ],
                      )
                    : Container();
              },
            );
          }
        });
  }
}

//========================================================================================
class ListItem extends StatefulWidget {
  const ListItem({
    super.key,
    required this.name,
    required this.badge,
    required this.to,
    required this.oldMessage,
    required this.recentMessage,
    required this.recentMessageFrom,
  });
  final String name;
  final String to;
  final String badge;
  final List oldMessage;
  final List recentMessage;
  final String recentMessageFrom;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
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

  String hourMinute(Timestamp t) {
    DateTime dt = t.toDate();
    return int.parse(dt.hour.toString()).toString() +
        ":" +
        int.parse(dt.minute.toString()).toString();
  }

  String checkLength(String message) {
    if (message.length > 33) {
      return '${message.substring(0, 24)} ...';
    }
    return message;
  }

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
              padding: const EdgeInsets.symmetric(vertical: 5.0),
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
                          widget.recentMessage.isNotEmpty &&
                                  !(widget.recentMessageFrom == widget.name)
                              ? Text(
                                  checkLength(
                                      widget.recentMessage.last['message']),
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Color(0xFF1A2321),
                                  ),
                                )
                              : widget.oldMessage.isNotEmpty
                                  ? Text(
                                      checkLength(
                                          widget.oldMessage.last['message']),
                                      style: const TextStyle(
                                          fontSize: 12.0,
                                          color: Color(0xFF9DA1A0)),
                                    )
                                  : const Text(
                                      "Herhangi bir mesaj bulunmuyor",
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 5.0, 0.0, 0.0),
                      child: Column(children: [
                        widget.recentMessage.isNotEmpty &&
                                !(widget.recentMessageFrom == widget.name)
                            ? Text(
                                hourMinute(
                                    widget.recentMessage.last['timestamp']),
                                style: const TextStyle(fontSize: 12.0),
                              )
                            : widget.oldMessage.isNotEmpty
                                ? Text(
                                    hourMinute(
                                        widget.oldMessage.last['timestamp']),
                                    style: const TextStyle(fontSize: 12.0),
                                  )
                                : Container(),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0)),
                        widget.recentMessage.isNotEmpty &&
                                !(widget.recentMessageFrom == widget.name)
                            ? Container(
                                decoration: const BoxDecoration(
                                    color: Color(0xFF004834),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(100),
                                      topRight: Radius.circular(100),
                                      bottomLeft: Radius.circular(100),
                                      bottomRight: Radius.circular(100),
                                    )),
                                padding: const EdgeInsets.only(
                                    top: 0, bottom: 0, left: 7, right: 7),
                                child: Text(
                                  widget.recentMessage.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.0,
                                  ),
                                ),
                              )
                            : Container(),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
