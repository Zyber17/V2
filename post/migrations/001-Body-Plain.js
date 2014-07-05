// Generated by CoffeeScript 1.6.3
(function() {
  var db, htmlToText, up;

  db = require('../db');

  htmlToText = require('html-to-text');

  up = function() {
    return db.Articles.find().select({
      body: 1
    }).exec(function(err, articles) {
      var article, i, _i, _len, _results;
      if (!err) {
        if (articles.length) {
          _results = [];
          for (i = _i = 0, _len = articles.length; _i < _len; i = ++_i) {
            article = articles[i];
            if (article != null) {
              if (article.body != null) {
                if (article.body[0] != null) {
                  if (article.body[0].body != null) {
                    console.log(JSON.stringify(article));
                    article.bodyPlain = (htmlToText.fromString(article.body[0].body)).toString();
                    article.save(function(err, resp) {
                      return console.log(err ? JSON.stringify(err) : "Okay: " + i);
                    });
                    if ((i + 1) === articles.length) {
                      _results.push(process.exit());
                    } else {
                      _results.push(void 0);
                    }
                  } else {
                    _results.push(void 0);
                  }
                } else {
                  _results.push(void 0);
                }
              } else {
                _results.push(void 0);
              }
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        }
      } else {
        console.log("Error (articles): " + err);
      }
    });
  };

  up();

}).call(this);
