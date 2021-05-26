{

  document.documentElement.style.margin = "0";
  document.documentElement.style.height = "100%";
  document.documentElement.style.overflow = "hidden";
  document.documentElement.style.position = "fixed";

  document.body.style.margin = "0";
  document.body.style.height = "100%";
  document.body.style.overflow = "hidden";
  document.body.style.position = "fixed";
  document.body.style.backgroundColor = "black";

  var node = document.createElement("DIV");                 // Create a <li> node
  node.id = "container";                         // Append the text to <li>
  document.body.appendChild(node);     // Append <li> to <ul> with id="myList"

  document.querySelector("#container").innerHTML = window.atob(`{{{html}}}`);
  const CODE = window.atob(`{{{code}}}`);
  const META = (function() {
    let image_lookup = JSON.parse(window.atob(`{{{images}}}`));
    let promise_set = new Set(`{{{image_keys}}}`.split("|"));
    let faved = {{ faved }};
    let promise_lookup = {};
    let likeClasses = [ "fav", "svg-icon", "svg-heart" ];
    if (faved) {
      likeClasses[likeClasses.length] = "svg-liked"
    }
    return {
      debug : false,
      name : `{{meta.name}}`, // Name and instruction are sanitized on store.
      instructions : `{{meta.instructions}}`,
      boundaries : {{ meta.boundaries }},
      impulse : {{ meta.impulse }},
      gravity : {{ meta.gravity }},
      external_cache : function(key, value) {
        // Set our cache value
        if (faved && !promise_set.has(key) && !(key in promise_lookup)) {
          SetCache.postMessage(`${key}|${value}`);
          promise_lookup[key] = new Promise(function(resolve) {
            window.addEventListener("set|" + key, function(event) {
              promise_set.add(key);
              resolve(event.detail.data);
            }, {once : true});
          });
        }
      },
      cache_proxy : function(src, key) {
        // Obviously make this endpoint.
        // Should check cache, and if cache fails, it should then stream.
        let lookup = src.split("gf://")[1];
        if (lookup in image_lookup) {
          src = image_lookup[lookup];
        }
        if (faved) {
          if (key in promise_lookup) {
            return promise_lookup[key];
          }
          if (promise_set.has(key)) {
            promise_lookup[key] = new Promise(function(resolve) {
              window.addEventListener(
                  key, function(event) { resolve(event.detail.data); },
                  {once : true});
            });
            GetCache.postMessage(key);
            return promise_lookup[key];
          }
        }
        return "https://api.carolinaignites.org/cors/" + src;
      },
      cache_background : faved && !promise_set.has("background"),
      set_score : function(score) {
        SetScore.postMessage(score);
        window.__highscore = score;
      },
      get_score : function() {
        GetScore.postMessage(0);
        return window.__highscore | 0;
      },
      gameover_hook :
          function() { GameOver.postMessage(window.__highscore | 0); },
      modal_hooks : [
        {
          "classes" : [ "report", "svg-icon", "svg-report" ],
          "onclick" : () => {
            Report.postMessage(0);
          }
        },
        {
          "classes" : [ "share", "svg-icon", "svg-share" ],
          "onclick" : () => { Share.postMessage(0); }
        },
        {
          "classes" : likeClasses,
          "onclick" : () => {
            let fav =
                document.querySelector(".fav").classList.toggle("svg-liked");
            ToggleLike.postMessage(0);
            faved = !faved;
          }
        },
      ]
    };
  })();

  new GameFrame(META, function(gf) {
    let collision = gf.collision;
    let gameOver = gf.gameOver;
    let score = gf.score;
    let remove = gf.remove;
    let registerKeys = gf.registerKeys;
    let registerLoops = gf.registerLoops;
    let template = gf.template;
    try {
      eval(CODE);
    } catch (e) {
      var err = e.constructor(e.message);
      err.lineNumber = e.lineNumber - err.lineNumber + 3;
      console.error(err);
      throw err;
    }
  });
}
