const String API_ENDPOINT = "https://api.carolinaignites.org";
const String API_SEARCH = "$API_ENDPOINT/search?search=";
const String API_SOME = "$API_ENDPOINT/some";
const String GAME_ASSET = "assets/game/game.html";
///////////////////////////////////
//     J                      S
// ░░░░░░░░▄▄▄▄▄░░░░░▄▄▄▄▄░░░░░░░░░
// ░░░░░▄█████████▄█████████▄░░░░░░
// ░░▄█████████████████████████▄░░░
// ████████████████████████████████
// ██████████████▀░▀███████████████
// ████████████▀░░░░░▀█████████████
// ░▀▀▀▀▀▀▀▀▀░░░░░░░░░░░▀▀▀▀▀▀▀▀▀░░
const String JS_MUSTACHE = "assets/the.stache.js";
// published games have the prefix "published_"
const String PUBLISHED = "published_";
const int KEY_OFFSET = PUBLISHED.length; // = 10

// A single black pixel (█) in base64, incase image caching breaks.
const String BLACK_PIXEL = "data:image/gif;base64,"
    "R0lGODlhA"
    "QABAIAAAA"
    "UEBAAAACw"
    "AAAAAAQAB"
    "AAACAkQBADs=";

// @media screen is needed, because only 1 rule at a time can be added to a
// style sheet. However, this way, bulk rules can be added.
const String CSS_TEMPLATE = """{
  let style = document.createElement('style');
  document.head.appendChild(style);
  style.sheet.insertRule(`
  @media screen {
    {{{css}}}
  }`);
}""";

// Assets to load in nested by priority.
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

// Information pages in Nav Drawer
const String ABOUT_PAGE = "assets/pages/about.md";
const String LICENSE_PAGE = "assets/pages/license.md";
const String PRIVACY_PAGE = "assets/pages/privacy.md";
