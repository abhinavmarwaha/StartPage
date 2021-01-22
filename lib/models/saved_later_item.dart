import 'dart:convert';

class SavedLaterItem {
  final int id;
  final String title;
  final String url;
  final String cat;

  SavedLaterItem({
    this.id,
    this.title,
    this.url,
    this.cat,
  });

  SavedLaterItem copyWith({
    int id,
    String title,
    String url,
    String cat,
  }) {
    return SavedLaterItem(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      cat: cat ?? this.cat,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'cat': cat,
    };
  }

  factory SavedLaterItem.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return SavedLaterItem(
      id: map['id'],
      title: map['title'],
      url: map['url'],
      cat: map['cat'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SavedLaterItem.fromJson(String source) =>
      SavedLaterItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SavedLaterItem(id: $id, title: $title, url: $url, cat: $cat)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is SavedLaterItem &&
        o.id == id &&
        o.title == title &&
        o.url == url &&
        o.cat == cat;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ url.hashCode ^ cat.hashCode;
  }
}
