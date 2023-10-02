import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../blocs/user/user_bloc.dart';

typedef City = String;
List<City> cities = <String>[
  "Adrar",
  "Chlef",
  "Laghouat",
  "Oum El Bouaghi",
  "Batna",
  "Bejaia",
  "Biskra",
  "Bechar",
  "Blida",
  "Bouira",
  "Tamanrasset",
  "Tebessa",
  "Tlemcen",
  "Tiaret",
  "Tizi Ouazou",
  "Alger",
  "Djelfa",
  "Jijel",
  "Setif",
  "Saida",
  "Skikda",
  "Sidi Bel Abbes",
  "Annaba",
  "Guelma",
  "constantine",
  "Medea",
  "Mostaganem",
  "M'Sila",
  "Mascara",
  "Ouargla",
  "Oran",
  "El Bayadh",
  "Illizi",
  "Bordj Bou Arreridj",
  "Boumerdes",
  "El Taref",
  "Tindouf",
  "Tissemsilt",
  "El Oued",
  "Khenchela",
  "Souk Ahras",
  "Tipaza",
  "Mila",
  "Ain Defla",
  "Naama",
  "Ain Temouchent",
  "Ghardaia",
  "Relizane",
  "Timimoun",
  "Bordj Badji Mokhtar",
  "Ouled Djellal",
  "Beni Abbes",
  "In Salah",
  "In Guezzam",
  "Touggourt",
  "Djanet",
  "El M'Ghair",
  "El Meniaa",
];

class User {
  /* Attributes */
  final String fullName;
  final String photoURL;
  final String phoneNumber;
  final String idCard;
  final String address;
  final City city;
  final String gender;
  final String uid;
  final UserRoles role;

//<editor-fold desc="Data Methods">
  const User({
    required this.fullName,
    required this.photoURL,
    required this.phoneNumber,
    required this.idCard,
    required this.address,
    required this.city,
    required this.gender,
    required this.uid,
    required this.role,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          runtimeType == other.runtimeType &&
          fullName == other.fullName &&
          photoURL == other.photoURL &&
          phoneNumber == other.phoneNumber &&
          idCard == other.idCard &&
          address == other.address &&
          city == other.city &&
          gender == other.gender &&
          uid == other.uid &&
          role == other.role);

  @override
  int get hashCode =>
      fullName.hashCode ^
      photoURL.hashCode ^
      phoneNumber.hashCode ^
      idCard.hashCode ^
      address.hashCode ^
      city.hashCode ^
      gender.hashCode ^
      uid.hashCode ^
      role.hashCode;

  @override
  String toString() {
    return 'User{ fullName: $fullName, photoURL: $photoURL, phoneNumber: $phoneNumber, idCard: $idCard, address: $address, city: $city, gender: $gender, uid: $uid, role: $role,}';
  }

  User copyWith({
    String? fullName,
    String? photoURL,
    String? phoneNumber,
    String? idCard,
    String? address,
    String? city,
    String? gender,
    String? uid,
    UserRoles? role,
  }) {
    return User(
      fullName: fullName ?? this.fullName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      idCard: idCard ?? this.idCard,
      address: address ?? this.address,
      city: city ?? this.city,
      gender: gender ?? this.gender,
      uid: uid ?? this.uid,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fullName': fullName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'idCard': idCard,
      'address': address,
      'city': city,
      'gender': gender,
      'uid': uid,
      'role': describeEnum(role),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      fullName: map['fullName'] as String,
      photoURL: map['photoURL'] as String,
      phoneNumber: map['phoneNumber'] as String,
      idCard: map['idCard'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      gender: map['gender'] as String,
      uid: map['uid'] as String,
      role: UserRoles.values
          .firstWhere((element) => describeEnum(element) == map['role']),
    );
  }

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
//

//</editor-fold>
}
