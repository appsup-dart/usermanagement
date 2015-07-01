
part of usermanagement;

_randomString([int count = 220]) {
  var r = new Random();
  const String characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  return new Iterable.generate(count, (i)=>characters[r.nextInt(characters.length)]).join();
}

class AccessToken {
  final String accessToken;
  final DateTime expiresAt;
  final String username;

  AccessToken._(this.username, this.accessToken, this.expiresAt);

  static AccessToken create(String username, [Duration duration = const Duration(days: 1)]) =>
  new AccessToken._(username, _randomString(), new DateTime.now().add(duration));


  bool get isExpired => expiresAt.isAfter(new DateTime.now());

}
