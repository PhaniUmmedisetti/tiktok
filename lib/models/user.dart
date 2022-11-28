import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name;
  String profileUrl;
  String email;
  String uid;

  User({
    required this.name,
    required this.profileUrl,
    required this.email,
    required this.uid,
  });
  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "profileUrl": profileUrl,
        "uid": uid,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
      email: snapshot['email'],
      name: snapshot['name'],
      profileUrl: snapshot['profileUrl'],
      uid: snapshot['uid'],
    );
  }
}
