import 'dart:core';

class Game {
  String hash;
  String name;
  String description;
  String json;
  int highscore;
  int plays;
  bool favourited;
  bool saved;

  Game({
    this.hash,
    this.name,
    this.description,
    this.json,
    this.highscore,
    this.plays,
    this.favourited,
    this.saved,
  });

  // API is out of sync from this. Ideally fix. Too lazy rn.
  factory Game.fromMap(Map<String, dynamic> json) => new Game(
        hash: json["id"],
        name: json["title"],
        description: json["instructions"],
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
        "json": json,
        "highscore": highscore,
        "plays": plays,
        "favourited": favourited,
        "saved": saved,
      };
}
