import 'dart:io';
import "dart:math";
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:async/async.dart';
import 'dart:convert';
import 'package:flutter/scheduler.dart';

import 'package:http/http.dart' as http;

import 'package:reflected_mustache/mustache.dart';
import 'Constants.dart';
import 'Database.dart';
import 'Game.dart';

class PageBuilder {
  static final PageBuilder _singleton = new PageBuilder._internal();

  PageBuilder._internal();
  String _page;
  Template _css_template = new Template(CSS_TEMPLATE);
  Template _template;
  Map<String, String> _assets = {};

  factory PageBuilder() {
    return _singleton;
  }

  Future<String> _loadCss(String css) async {
    if (_assets.containsKey(css)) {
      return _assets[css];
    }
    return rootBundle.loadString(css).then((source) {
      _assets[css] =
          _css_template.renderString({"css": source.replaceAll("\n", "")});
      return _assets[css];
    });
  }

  Future<String> _loadJs(String js) async {
    if (_assets.containsKey(js)) {
      return _assets[js];
    }
    return rootBundle.loadString(js).then((source) {
      _assets[js] = source;
      return _assets[js];
    });
  }

  //function to get the data field of the gameframe game
  Future<String> _queryGame(Game game) async {
    if (game.json != null) {
      return game.json;
    }
    final DBProvider db = DBProvider.db;
    String key = game.hash.substring(KEY_OFFSET);
    return http.get(Uri.encodeFull("${API_ENDPOINT}/${key}"), headers: {
      //if your api require key then pass your key here as well e.g "key": "my-long-key"
      "Accept": "application/json"
    }).then((response) {
      var body = json.decode(response.body);
      String data = utf8.decode(base64.decode(body["data"]));
      game.json = data;
      db.updateGame(game);
      return data;
    });
  }

  Future<Template> _loadTemplate() async {
    if (_template == null) {
      return rootBundle.loadString(JS_MUSTACHE).then((source) {
        _template = new Template(source);
        return _template;
      });
    }
    return _template;
  }

  Future<void> _load_batch(List<String> csses, List<String> jses, controller) {
    var futures = <Future>[];
    for (var css in csses) {
      futures.add(_loadCss(css)
          .then((source) => controller.evaluateJavascript(source)));
    }
    for (var js in jses) {
      futures.add(
          _loadJs(js).then((source) => controller.evaluateJavascript(source)));
    }
    return Future.wait(futures);
  }

  Future loadSources(Game game, controller) async {
    // We have to load sources manually, because we cannot load sources from a
    // URI. There is a way to render a local HTML file in flutter, but the pull
    // request has not come through yet (see
    // https://github.com/flutter/plugins/pull/1247)
    List<String> csses;
    List<String> jses;
    for (int i = 0;
        i < max(CSS_ASSETS_BY_PRIORITY.length, JS_ASSETS_BY_PRIORITY.length);
        i++) {
      csses = [];
      jses = [];
      if (i < CSS_ASSETS_BY_PRIORITY.length) {
        csses = CSS_ASSETS_BY_PRIORITY[i];
      }
      if (i < JS_ASSETS_BY_PRIORITY.length) {
        jses = JS_ASSETS_BY_PRIORITY[i];
      }
      await _load_batch(csses, jses, controller);
    }

    // Now we load the game.
    _loadTemplate().then((template) {
      return _queryGame(game).then((data) {
        controller.evaluateJavascript(template.renderString(json.decode(data)));
      });
    });
  }

  Future<String> getPage() async {
    if (_page == null) {
      return rootBundle.loadString(GAME_ASSET).then((page) {
        _page = Uri.dataFromString(page,
                mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
            .toString();
        return _page;
      });
    }
    return _page;
  }
}
