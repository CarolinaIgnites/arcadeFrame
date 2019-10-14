const String API_ENDPOINT = "https://api.carolinaignites.org";
const String API_SEARCH = "${API_ENDPOINT}/search?search=";
const String API_SOME = "${API_ENDPOINT}/some";
const String GAME_ASSET = "assets/game/game.html";
const String JS_MUSTACHE = "assets/the.stache.js";
const int KEY_OFFSET = 10;
const String CSS_TEMPLATE = """{
  let style = document.createElement('style');
  document.head.appendChild(style);
  style.sheet.insertRule(`
  @media screen {
    {{{css}}}
  }`);
}""";

const List<List<String>> JS_ASSETS_BY_PRIORITY = [
  ["assets/game/js/physicsjs-full.min.js"],
  [
    "assets/game/js/nipplejs.js",
    "assets/game/js/interactive-custom.js",
  ],
  ["assets/game/js/gameframe.js"]
];
const List<List<String>> CSS_ASSETS_BY_PRIORITY = [
  ["assets/game/css/minimal.css"],
  ["assets/game/css/gameframe.css"],
];
