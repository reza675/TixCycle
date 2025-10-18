import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final int coins;
  final Timestamp timeCreated;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.coins=0,
    this.profileImageUrl,
    required this.timeCreated,

  });

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      id: snapshot.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      coins: data['coins'] ?? 0,
      profileImageUrl: data['profileImageUrl'],
      timeCreated: data['timeCreated'] ?? Timestamp.now(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      displayName: json['displayName'],
      coins: json['coins'],
      profileImageUrl: json['profileImageUrl'],
      timeCreated: json['timeCreated'] ?? Timestamp.now(),
    );
  }

    Map<String, dynamic> toJson(){
      return {
        'id' : id,
        'username' : username,
        'email' : email,
        'displayName' : displayName,
        'coins' : coins,
        'profileImageUrl' : profileImageUrl,
        'timeCreated' : timeCreated,
      };
    }
}
