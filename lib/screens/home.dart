//import 'dart:html';

import 'package:rating_chat2/models/user.dart';
import 'package:rating_chat2/screens/chat_screen.dart';
import 'package:rating_chat2/screens/search_screen.dart';
import 'package:rating_chat2/services/auth_bloc.dart';
import 'package:rating_chat2/screens/signin.dart';
import 'package:provider/provider.dart';
import 'package:rating_chat2/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rating_chat2/widgets/single_message.dart';

class HomePage extends StatefulWidget {
  UserModel user;
  HomePage(this.user);

  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  final _postController = TextEditingController();
  late String valueText;
  late String postText;
  List<Map> searchResult = [];

  void loadChats() async {
    await FirebaseFirestore.instance.collection('users').get().then((value) {
      if (value.docs.length < 1) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("no recent chats")));
        return;
      }
      value.docs.forEach((user) {
        if (user.data()['email'] != widget.user.email) {
          searchResult.add(user.data());
        }
      });
    });
  }

  @override
  void initState() {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    authBloc.currentUser.listen((fbUser) {
      if (fbUser == null) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SignInPage()));
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Convos'),
          centerTitle: true,
          backgroundColor: Colors.black,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () {
                authBloc.logout();
              },
            )
          ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchScreen(widget.user)));
        },
      ),
      body: Column(
        children: [
          StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.docs.length < 1) {
                    return Center(
                      child: Text("didnt load properly"),
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      reverse: true,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        //return Text(snapshot.data.docs[index]);
                        //return Text(snapshot.data.docs[index]['name']);
                        return ListTile(
                            leading: CircleAvatar(),
                            title: Text(snapshot.data.docs[index]['name']),
                            subtitle: Text(snapshot.data.docs[index]['email']),
                            trailing: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      currentUser: widget.user,
                                      receiverId: snapshot.data.docs[index]
                                          ['uid'],
                                      receiverName: snapshot.data.docs[index]
                                          ['name'],
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.message),
                            ));
                      });
                } else {
                  return Center(
                    child: Text("something wrong"),
                  );
                }
              })
        ],
      ),
    );
  }
}
