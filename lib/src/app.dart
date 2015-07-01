
part of usermanagement;

class App {
  final String appKey;

  final UserBase userBase;

  final String emailHtml;

  static final String _appDir = "$rootDataDir/apps";

  static Map<String, App> __apps = null;
  static Map<String,App> get _apps {
    if (__apps==null) {
      __apps = {};
      for (var d in new Directory(_appDir).listSync()) {
        if (d is! Directory) continue;
        String name = d.path.split(Platform.pathSeparator).last;
        String email = new File(d.path+Platform.pathSeparator+"passreset_email.html").readAsStringSync();
        __apps[name] = new App(name, emailHtml: email);
      }
    }
    return __apps;
  }

  App(String appKey, {UserBase userBase, this.emailHtml}) :
    this.appKey = appKey,
    this.userBase = userBase==null ? new UserBase(appKey) : userBase;


  static List<App> list() => _apps.values.toList(growable: false);

  static App find(String key) => _apps[key];
}
