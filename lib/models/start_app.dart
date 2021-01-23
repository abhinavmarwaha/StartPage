import 'dart:convert';

class StartApp {
  final int id;
  final String title;
  final String url;
  String cat;
  final bool app;
  String color;

  StartApp({this.id, this.title, this.url, this.cat, this.app, this.color});

  StartApp copyWith({
    int id,
    String title,
    String url,
    String cat,
    bool app,
  }) {
    return StartApp(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      cat: cat ?? this.cat,
      app: app ?? this.app,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'cat': cat,
      'app': app ? 1 : 0,
      'color': color
    };
  }

  factory StartApp.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return StartApp(
      id: map['id'],
      title: map['title'],
      url: map['url'],
      cat: map['cat'],
      color: map['color'],
      app: map['app'] == 1 ? true : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory StartApp.fromJson(String source) =>
      StartApp.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StartApp(id: $id, title: $title, url: $url, cat: $cat, app: $app)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is StartApp &&
        o.id == id &&
        o.title == title &&
        o.url == url &&
        o.cat == cat &&
        o.app == app;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        url.hashCode ^
        cat.hashCode ^
        app.hashCode;
  }
}
