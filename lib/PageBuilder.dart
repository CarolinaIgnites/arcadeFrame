import "dart:math";
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:reflected_mustache/mustache.dart';
import 'Constants.dart';
import 'Game.dart';
import 'GameBLoC.dart';

class PageBuilder {
  static final PageBuilder _singleton = new PageBuilder._internal();

  PageBuilder._internal();
  String _page;
  Template _cssTemplate = new Template(CSS_TEMPLATE);
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
      // Not sure if replacing \n is needed. Particular api used is finiky.
      _assets[css] =
          _cssTemplate.renderString({"css": source.replaceAll("\n", "")});
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

  // Check if we already have the data, otherwise load it.
  Future<String> _queryGame(Game game, GameBLoC bloc) async {
    debugPrint(game.json);
    if (game.json == null) {
      game = await bloc.queryGame(game.hash);
    }
    return game.json;
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

  // Probably a cleaner way to do this.
  Future<void> _loadBatch(List<String> csses, List<String> jses, controller) {
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

  Future loadSources(Game game, controller, GameBLoC bloc) async {
    // We have to load sources manually, because we cannot load sources from a
    // URI. There is a way to render a local HTML file in flutter, but the pull
    // request has not come through yet (see
    // https://github.com/flutter/plugins/pull/1247)
    // As hacky as this is, it does work.
    List<String> csses;
    List<String> jses;
    // Def a cleaner way to do this.
    final int loads =
        max(CSS_ASSETS_BY_PRIORITY.length, JS_ASSETS_BY_PRIORITY.length);
    for (int i = 0; i < loads; i++) {
      csses = [];
      jses = [];
      if (i < CSS_ASSETS_BY_PRIORITY.length) {
        csses = CSS_ASSETS_BY_PRIORITY[i];
      }
      if (i < JS_ASSETS_BY_PRIORITY.length) {
        jses = JS_ASSETS_BY_PRIORITY[i];
      }
      // Block to load all assets of this level.
      // Note there is a bug where bootstrap doesn't load. Hmm :/
      await _loadBatch(csses, jses, controller);
    }

    // Now we load the game.
    _loadTemplate().then((template) {
      return _queryGame(game, bloc).then((data) {
        game.json = data;
        var template_data = json.decode(data);
        template_data["image_keys"] = game.images.join("|");
        template_data["faved"] = game.favourited;
        controller.evaluateJavascript(template.renderString(template_data));
      });
    });
  }

  // What a hack.
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
