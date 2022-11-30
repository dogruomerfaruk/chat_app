import 'package:cloud_firestore/cloud_firestore.dart';

List<Map<String, dynamic>> oldMessages1 = [
  {
    'message': 'nabererer',
    'sender': 'Ali',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'iyi sneden',
    'sender': 'Ahmet',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'harikasdkasdkaksdkasdkaskdaw',
    'sender': 'Ali',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'superrr',
    'sender': 'Ali',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'tammam',
    'sender': 'Ahmet',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'obaa',
    'sender': 'Ali',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'okk',
    'sender': 'Ali',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'rmmm',
    'sender': 'Ali',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'superrr',
    'sender': 'Ali',
    'timestamp': DateTime.now(),
  },
];

List<Map<String, dynamic>> recentMessages1 = [
  {
    'message': 'obaa',
    'sender': 'Ali',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'okk',
    'sender': 'Ali',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'rmmm',
    'sender': 'Ali',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'superrr',
    'sender': 'Ali',
    'timestamp': DateTime.now(),
  },
];

List<Map<String, dynamic>> oldMessages2 = [
  {
    'message': 'NHNHGVHNV',
    'sender': 'John',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'iyi GHFHGF',
    'sender': 'Ahmet',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'hVCVCVCsdkas54654dkaksdkasdkaskdaw',
    'sender': 'John',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'superrr',
    'sender': 'John',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'tammam',
    'sender': 'Ahmet',
    'timestamp': DateTime.now(),
  },
  {
    'message': 'qweqweq',
    'sender': 'John',
    'timestamp': DateTime.now(),
  },
  {
    'message': '123123 sneden',
    'sender': 'John',
    'timestamp': DateTime.now(),
  },
  {
    'message': '13rrrrfedfdsf  dsadas asd ',
    'sender': 'John',
    'timestamp': DateTime.now(),
  },
];

List<Map<String, dynamic>> recentMessages2 = [
  {
    'message': 'qweqweq',
    'sender': 'John',
    'timestamp': DateTime.now(),
  },
  {
    'message': '123123 sneden',
    'sender': 'John',
    'timestamp': DateTime.now(),
  },
  {
    'message': '13rrrrfedfdsf  dsadas asd ',
    'sender': 'John',
    'timestamp': DateTime.now(),
  },
];

void initmock() {
  CollectionReference chat = FirebaseFirestore.instance.collection("chats");
  chat.doc("1").set({
    "id": "1",
    "user1": "Ahmet",
    "user2": "Ali",
    "badge": "Yeni eslesme",
    "recentMessageFrom": "Ali",
    "oldMessages": oldMessages1,
    "recentMessages": recentMessages1,
  });

  chat.doc("2").set({
    "id": "2",
    "user1": "Ahmet",
    "user2": "John",
    "badge": "Beklemede",
    "recentMessageFrom": "John",
    "oldMessages": oldMessages2,
    "recentMessages": recentMessages2,
  });
}
