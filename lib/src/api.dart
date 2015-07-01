
part of usermanagement;

@ApiClass(name: 'usermanagement', version: 'v1')
class UserManagementApi {

  @ApiMethod(method: 'POST', path: 'signin')
  Future<AccessToken> signin(Credentials credentials) async {
    App app = App.find(credentials.appKey);
    if (credentials.username==null||credentials.password==null)
      throw new BadRequestError("No username or password.");
    if (!app.userBase.checkCredentials(credentials.username, credentials.password))
      throw new UnauthorizedException("Credentials did not match.");

    return _createToken(credentials.username);
  }

  AccessToken _createToken(String username) {
    var token = AccessToken.create(username);
    tokens[token.accessToken] = token;

    return token;
  }

  @ApiMethod(method: 'POST', path: 'signup')
  Future<AccessToken> signup(Credentials credentials) async {
    App app = App.find(credentials.appKey);
    if (credentials.username==null||credentials.password==null)
      throw new BadRequestError("No username or password.");
    if (app.userBase.lookup(credentials.username)!=null)
      throw new ConflictException("User already exists.");

    app.userBase.create(credentials);
    return _createToken(credentials.username);
  }

  @ApiResource(name: 'password')
  PasswordResource password = new PasswordResource();

  @ApiResource(name: "oauth")
  OAuthResource oauth = new OAuthResource();
}

class OAuthResource {
  @ApiMethod(method: 'GET', path: 'oauth/token')
  Future<AccessToken> token({String access_token}) async {
    if (tokens.containsKey(access_token))
      return tokens[access_token];

    throw new BadRequestError("Invalid token.");
  }

}

class PasswordResource {

  Map<String, String> _tokens = {};

  @ApiMethod(method: 'GET', path: 'password/reset/{token}')
  Future<Credentials> get(String token, {String app_key}) {
    if (app_key==null)
      throw new BadRequestError("App key is null.");
    if (_tokens.containsKey(token))
      throw new NotFoundError("Reset token not found.");

    var key = app_key+":"+token;
    var username = _tokens[key];

    return new Credentials()
      ..appKey = app_key
      ..username = username;
  }

  @ApiMethod(method: 'PUT', path: 'password/reset/{token}')
  Future<Credentials> change(String token, Credentials credentials) {
    if (credentials.appKey==null||credentials.password==null)
      throw new BadRequestError("App key or password is null.");
    if (_tokens.containsKey(token))
      throw new NotFoundError("Reset token not found.");

    var key = credentials.appKey+":"+token;
    var username = _tokens[key];
    App app = App.find(credentials.appKey);
    credentials.username = username;
    app.userBase.updatePassword(credentials);

    _tokens.remove(key);
    return new Credentials()
      ..appKey = credentials.appKey
      ..username = username;
  }

  @ApiMethod(method: 'POST', path: 'password/reset')
  Future<VoidMessage> reset(Credentials credentials) async {
    App app = App.find(credentials.appKey);
    if (credentials.username==null)
      throw new BadRequestError("No username.");

    var user = app.userBase.lookup(credentials.username);
    if (user==null)
      throw new NotFoundError("User does not exist.");

    String token = _randomString(10);
    _tokens[credentials.appKey+":"+token] = credentials.username;

    var options = new SmtpOptions()
      ..hostName = "smtprelay.ugent.be"
      ..port = 25;

    var emailTransport = new SmtpTransport(options);

    // Create our mail/envelope.
    var envelope = new Envelope()
      ..from = 'noreply@fietstelweek.be'
      ..recipients.add(credentials.username)
      ..subject = 'Fietstelweek - Wachtwoordreset'
      ..html = App.find(credentials.appKey).emailHtml.replaceAll("%TOKEN%",token);

    // Email it.
    await emailTransport.send(envelope);

    return null;
  }
}


class UnauthorizedException extends RpcError {
  UnauthorizedException([String message = "Unauthorized."]) : super(401, "Unauthorized", message);
}

class ForbiddenException extends RpcError {
  ForbiddenException([String message = "Forbidden."]) : super(403, "Forbidden", message);
}

class ConflictException extends RpcError {
  ConflictException([String message = "Conflict."]) : super(409, "Conflict", message);
}

