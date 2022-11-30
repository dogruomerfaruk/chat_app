import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/widgets/appbar.dart';
import 'package:my_app/screens/messages.dart';
import 'package:my_app/screens/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    Messages(name: "Ahmet", chatIDs: ["1", "2", "3"]),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: const AppBarChat(),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (_onItemTapped),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String user = "";

  saveUserData(value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('user', value);
    setState(() {
      user = value;
    });
  }

// Read Data
  getUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String user3 = sharedPreferences.getString('user') ?? "";
    return user3;
  }

  final users = FirebaseFirestore.instance
      .collection('users')
      //.where('username', isEqualTo: widget.name)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<QuerySnapshot>(
          stream: users,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              print("errorror");
              return const Text("errrrr");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              print("waiting");
              return const Text("connecting");
            } else {
              return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: snapshot.data.docs.length, // items length
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: user == snapshot.data.docs[index]['username']
                          ? Colors.yellow
                          : Colors.white,
                      title: Text(snapshot.data.docs[index]['username']),
                      onTap: () {
                        saveUserData(snapshot.data.docs[index]['username']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Messages(
                                  name: snapshot.data.docs[index]['username'],
                                  chatIDs: snapshot.data.docs[index]
                                      ['chatIDs'])),
                        );
                      },
                    );
                  });
            }
          }),
    );
  }
}
