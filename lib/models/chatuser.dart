class ChatUser {
  ChatUser({
    required this.profilePic,
    required this.about,
    required this.name,
    required this.username,
    required this.createdAt,
    required this.isOnline,
    required this.uid,
    required this.lastActive,
    required this.email,
    required this.pushToken,
  });

  late final String profilePic;
  late final String about;
  late final String name;
  late final String username;
  late final String createdAt; // Potentially problematic field
  late final bool isOnline;
  late final String uid;
  late final String lastActive;
  late final String email;
  late final String pushToken;

  ChatUser.fromJson(Map<String, dynamic> json) {
    profilePic = json['profilePic'] ?? ''; // Provide default value
    about = json['about'] ?? ''; // Provide default value
    name = json['name'] ?? ''; // Provide default value
    username = json['username'] ?? ''; // Provide default value
    createdAt = json['createdAt'] ?? ''; // Ensure createdAt is initialized
    isOnline = json['isOnline'] ?? false; // Default to false if not present
    uid = json['uid'] ?? ''; // Use 'uid' for id
    lastActive = json['lastActive'] ?? ''; // Provide default value
    email = json['email'] ?? ''; // Provide default value
    pushToken = json['pushToken'] ?? ''; // Provide default value
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['profilePic'] = profilePic;
    data['about'] = about;
    data['name'] = name;
    data['username'] = username;
    data['createdAt'] = createdAt;
    data['uid'] = uid;
    data['lastActive'] = lastActive;
    data['email'] = email;
    data['pushToken'] = pushToken;
    return data;
  }

  @override
  String toString() {
    return 'ChatUser('
        'profilePic: $profilePic, '
        'about: $about, '
        'name: $name, '
        'username: $username, '
        'createdAt: $createdAt, '
        'isOnline: $isOnline, '
        'uid: $uid, '
        'lastActive: $lastActive, '
        'email: $email, '
        'pushToken: $pushToken'
        ')';
  }
}
