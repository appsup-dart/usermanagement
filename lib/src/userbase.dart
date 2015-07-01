
part of usermanagement;

class Credentials {
  String username;
  String password;
  String appKey;

  toJson() => {
    "username": username,
    "password": password,
    "app_key": appKey
  };

  Credentials();
  Credentials.fromJson(Map<String,String> json) : username = json["username"], password = json["password"], appKey = json["app_key"];

}

class User {
  final String id;
  final Credentials credentials;

  toJson() => {
    "id": id,
    "credentials": credentials,
  };

  User({this.id, this.credentials}) {
    if (this.id==null||this.id.isEmpty)
      throw new ArgumentError("User id cannot be null or empty.");
    if (this.credentials==null||
        this.credentials.username==null||this.credentials.username.isEmpty||
        this.credentials.password==null||this.credentials.password.isEmpty)
      throw new ArgumentError("Username and password cannot be null or empty.");
  }

  User.fromJson(Map json) : this(
    id: json["id"],
    credentials: new Credentials.fromJson(json["credentials"])
  );
  User.fromCredentials(Credentials credentials) : this(
    id: credentials.username,
    credentials: credentials
  );

}


class UserBase {

  final String appKey;

  Map<String, User> _usersById = {};
  Map<String, User> _usersByUsername = {};

  UserBase(this.appKey) {
    for (var f in new Directory("${App._appDir}/$appKey/users").listSync()) {
      if (f is! File) continue;
      if (!f.path.endsWith(".json")) continue;
      var c = new User.fromJson(JSON.decode(f.readAsStringSync()));
      _addUser(c);
    }
  }

  _addUser(User user, {storeOnDisc: false}) {
    _usersById[user.id] = user;
    _usersByUsername[user.credentials.username] = user;

    if (storeOnDisc) {
      _storeUser(user);
    }
  }

  _storeUser(User user) {
    print("store");
    new File("${App._appDir}/$appKey/users/${user.id}.json").writeAsStringSync(new JsonEncoder.withIndent("  ").convert(user));
  }


  User lookup(String username) => _usersByUsername.containsKey(username) ?
    _usersByUsername[username] : null;

  bool checkCredentials(String username, String password) =>
    username!=null&&username.isNotEmpty&&password!=null&&password.isNotEmpty&&
    _usersByUsername.containsKey(username)&&_usersByUsername[username].credentials.password == password;

  create(Credentials credentials) {
    print("create $credentials");
    if (_usersByUsername.containsKey(credentials.username))
      throw new StateError("User already exists.");

    _addUser(new User.fromCredentials(credentials), storeOnDisc: true);
  }

  updatePassword(Credentials credentials) {
    if (!_usersByUsername.containsKey(credentials.username))
      throw new StateError("User does not exist.");

    var user = _usersByUsername[credentials.username];
    user.credentials.password = credentials.password;

    _storeUser(user);
  }

}
