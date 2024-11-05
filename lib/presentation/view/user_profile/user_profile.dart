class UserProfile {
  final String uid;
  final String username;
  final String email;
  final String country;
  final String profilePictureUrl;
  final String bio;

  UserProfile({
    required this.uid,
    required this.username,
    required this.email,
    required this.country,
    required this.profilePictureUrl,
    required this.bio,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'country': country,
      'profilePictureUrl': profilePictureUrl,
      'bio': bio,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      country: map['country'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      bio: map['bio'] ?? '',
    );
  }
}
