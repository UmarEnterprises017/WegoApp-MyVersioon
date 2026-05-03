import 'package:flutter/foundation.dart';

class UserModel {
  String name;
  String username;
  String bio;
  String email;
  String phone;
  String location;
  String avatarUrl;
  String gender;
  String language;

  UserModel({
    this.name = 'Jung Taekwoon',
    this.username = '@jungtaekwoon',
    this.bio = 'Living life to the fullest! 🌟',
    this.email = 'taekwoon@example.com',
    this.phone = '+82 10-1234-5678',
    this.location = 'Seoul, South Korea',
    this.avatarUrl = 'https://randomuser.me/api/portraits/men/52.jpg',
    this.gender = 'Male',
    this.language = 'English',
  });

  UserModel copyWith({
    String? name,
    String? username,
    String? bio,
    String? email,
    String? phone,
    String? location,
    String? avatarUrl,
    String? gender,
    String? language,
  }) {
    return UserModel(
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      language: language ?? this.language,
    );
  }
}

class UserProvider extends ChangeNotifier {
  UserModel _user = UserModel();

  UserModel get user => _user;

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void updateName(String name) {
    _user = _user.copyWith(name: name);
    notifyListeners();
  }

  void updateUsername(String username) {
    _user = _user.copyWith(username: username);
    notifyListeners();
  }

  void updateBio(String bio) {
    _user = _user.copyWith(bio: bio);
    notifyListeners();
  }

  void updateEmail(String email) {
    _user = _user.copyWith(email: email);
    notifyListeners();
  }

  void updatePhone(String phone) {
    _user = _user.copyWith(phone: phone);
    notifyListeners();
  }

  void updateLocation(String location) {
    _user = _user.copyWith(location: location);
    notifyListeners();
  }

  void updateAvatar(String avatarUrl) {
    _user = _user.copyWith(avatarUrl: avatarUrl);
    notifyListeners();
  }

  void updateGender(String gender) {
    _user = _user.copyWith(gender: gender);
    notifyListeners();
  }

  void updateLanguage(String language) {
    _user = _user.copyWith(language: language);
    notifyListeners();
  }
}
