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

  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('sw.js').then(
        function(registration) {
          console.log('Service worker registration succeeded:', registration);
        },
        function(error) {
          console.log('Service worker registration failed:', error);
        });
  } else {
    console.log('Service workers are not supported.');
  }

  let code = window.atob(`{{{code}}}`);
  let image_lookup = JSON.parse(window.atob(`{{{images}}}`));
  let meta = {
    debug : false,
    name : `{{meta.name}}`,
    instructions : `{{meta.instructions}}`,
    boundaries : {{meta.boundaries}},
    impulse : {{meta.impulse}},
    gravity : {{meta.gravity}},
    external_cache : function(key, value) {
      // Possibly leverage the app to store extra information
    },
    cache_proxy : function(src, key) {
      // Obviously make this endpoint.
      // Should check cache, and if cache fails, it should then stream.
      let lookup = src.split("gf://")[1];
      if (lookup in image_lookup) {
        src = image_lookup[lookup];
      }
      return "https://api.carolinaignites.org/cors/" + src;
      // Uncomment this line if coors doesn't work.
      // return src
    },
    set_score: function(score){SetScore.postMessage(score); window.__highscore = score;},
    get_score: function(){GetScore.postMessage(0); return window.__highscore | 0;},
  };

  let container = document.querySelector("#container");
  container.innerHTML = window.atob(`{{{html}}}`);

  new GameFrame(meta, function(gf) {
    let collision = gf.collision;
    let gameOver = gf.gameOver;
    let score = gf.score;
    let remove = gf.remove;
    let registerKeys = gf.registerKeys;
    let registerLoops = gf.registerLoops;
    let template = gf.template;
    try {
      eval(code);
    } catch (e) {
      var err = e.constructor(e.message);
      err.lineNumber = e.lineNumber - err.lineNumber + 3;
      console.error(err);
      throw err;
    }
  });
}
