import 'dart:core';

String sanitize(String s) {
  return s.replaceAll(new RegExp(r'[\{\}`\\]'), '');
}

String limit_string(String s, int limit) {
  s = sanitize(s);
  return s.length < limit ? s : s.substring(0, limit - 3) + "...";
}

class Game {
  String hash;
  String name;
  String description;
  String subtitle;
  List<String> images;
  String json;
  int highscore;
  int plays;
  bool favourited;
  bool saved;

  Game({
    this.hash,
    this.name,
    this.description,
    this.subtitle,
    this.images,
    this.json,
    this.highscore,
    this.plays,
    this.favourited,
    this.saved,
  });

  // API is out of sync from this. Ideally fix. Too lazy rn.
  factory Game.fromMap(Map<String, dynamic> json) => new Game(
        hash: json["id"],
        name: limit_string(json["title"] ?? "Untitled", 30),
        description:
            limit_string(json["instructions"] ?? "No instructions", 500),
        subtitle:
            limit_string(json["subtitle"] ?? json["instructions"] ?? "", 50),
        images: [],
        json: json["json"],
        highscore: 0,
        plays: 0,
        favourited: false,
        saved: false,
      );

  factory Game.fromRow(Map<String, dynamic> json) => new Game(
        hash: json["hash"],
        name: json["name"],
        description: json["description"],
        subtitle: json["subtitle"],
        images: (json["images"] ?? "").split("|"),
        json: json["json"],
        highscore: json["highscore"],
        plays: json["plays"],
        favourited: json["favourited"] == 1,
        saved: true,
      );

  Map<String, dynamic> toMap() => {
        "hash": hash,
        "name": name,
        "description": description,
        "subtitle": subtitle,
        "images": images.join("|"),
        "json": json,
        "highscore": highscore,
        "plays": plays,
        "favourited": favourited,
        "saved": saved,
      };
}
