import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final int coins;
  final Timestamp timeCreated;
  final String? profileImageUrl;
  final String? province;
  final Timestamp? birthOfDate;
  final String? phoneNumber;
  final String? occupation; 
  final String? city;      
  final String? gender;
  final String? idType;     
  final String? idNumber;
  final String role;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.coins=0,
    this.profileImageUrl,
    required this.timeCreated,
    this.province,
    this.birthOfDate,
    this.phoneNumber,
    this.occupation,
    this.city,
    this.gender,
    this.idType,
    this.idNumber,
    this.role = 'user',
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
      province: data['province'],
      birthOfDate: data['birthOfDate'],
      phoneNumber: data['phoneNumber'],
      occupation: data['occupation'],
      city: data['city'],
      gender: data['gender'],
      idType: data['idType'],
      idNumber: data['idNumber'],
      role: data['role'] ?? 'user',
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
      province: json['province'],
      birthOfDate: json['birthOfDate'],
      phoneNumber: json['phoneNumber'],
      occupation: json['occupation'],
      city: json['city'],
      gender: json['gender'],
      idType: json['idType'],
      idNumber: json['idNumber'],
      role: json['role'] ?? 'user',
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
        'province': province,
        'birthOfDate': birthOfDate,
        'phoneNumber': phoneNumber,
        'occupation': occupation,
        'city': city,
        'gender': gender,
        'idType': idType,
        'idNumber': idNumber,
        'role': role,
      };
    }
}
