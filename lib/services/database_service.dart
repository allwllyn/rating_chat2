/*
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rating_chat2/models/user.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Map<String, UserModel> userMap = <String, UserModel>{};
  static List<String> usernames = <String>[];

  final StreamController<Map<String, UserModel>> _usersController =
      StreamController<Map<String, UserModel>>();

  DatabaseService() {
    _firestore.collection('users').snapshots().listen(_usersUpdated);
  }

  Stream<Map<String, UserModel>> get users => _usersController.stream;

  void _usersUpdated(QuerySnapshot<Map<String, dynamic>> snapshot) {
    var users = _getUsersFromSnapshot(snapshot);
    _usersController.add(users);
  }
  
  Map<String, UserModel> _getUsersFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    for (var element in snapshot.docs) {
      UserModel user = UserModel.fromJson(element.id, element.data());
      userMap[user.uid] = user;
      usernames.add(user.name.toLowerCase());
    }

    return userMap;
  }
  
  void closeUser() async {
    await _usersController.close();
  }
}
*/
