// Hand crafted migrations :(
// At most add a couple of KB to app size, so no biggie in being verbose.

// Version 1
String gameTableV1([String name = "Games"]) {
  return "CREATE TABLE ${name}("
      "hash TEXT PRIMARY KEY,"
      "name TEXT,"
      "description TEXT,"
      "json TEXT,"
      "highscore INTEGER,"
      "plays INTEGER,"
      "favourited BIT,"
      "saved BIT"
      ")";
}

// Version 2
String imageTableV2([String name = "Images"]) {
  return "CREATE TABLE ${name}("
      "key TEXT PRIMARY KEY,"
      "data TEXT,"
      "game TEXT,"
      "FOREIGN KEY (game)"
      "REFERENCES Games (hash)"
      "   ON DELETE SET NULL"
      ")";
}

String gameTableV2([String name = "Games"]) {
  return "CREATE TABLE ${name}("
      "hash TEXT PRIMARY KEY,"
      "name TEXT,"
      "subtitle TEXT,"
      "images TEXT,"
      "description TEXT,"
      "json TEXT,"
      "highscore INTEGER,"
      "plays INTEGER,"
      "favourited BIT,"
      "saved BIT"
      ")";
}

List<String> gameTableV2Delta([String name = "Games"]) {
  return [
    "ALTER TABLE ${name} ADD COLUMN subtitle TEXT;",
    "ALTER TABLE ${name} ADD COLUMN images TEXT;"
  ];
}
