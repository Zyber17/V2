// Generated by CoffeeScript 1.6.3
(function() {
  var RSS, db, moment;

  RSS = require("rss");

  moment = require("moment");

  db = require("../db");

  module.exports = function(req, res, next) {
    var feed;
    feed = new RSS({
      title: "Pine View Torch",
      description: "The Torch is a student newspaper, distributed at Pine View School in Osprey, Florida.",
      feed_url: "http://pineviewtorch.com/rss",
      site_url: "http://pineviewtorch.com/",
      /*
      			Fix this later
      			image_url:
      				"http://pineviewtorch.com/TBD.image"
      */

      author: "Pine View Torch",
      webMaster: 'Zackary Corbett',
      copyright: "" + (new Date().getFullYear()) + " Pine View Torch",
      language: 'en'
    });
    return db.Articles.find({
      publishDate: {
        $lte: moment().toDate()
      },
      status: 4
    }, {
      publishDate: 1,
      body: 1,
      title: 1,
      author: 1,
      slug: 1
    }).sort('-publishDate').limit(15).execFind(function(err, resp) {
      var article, _i, _len;
      if (!err) {
        if (resp) {
          for (_i = 0, _len = resp.length; _i < _len; _i++) {
            article = resp[_i];
            feed.item({
              title: article.title,
              description: article.body[0].body,
              url: "http://pineviewtorch.com/articles/" + article.slug,
              guid: article._id.toString(),
              author: article.author,
              date: article.publishDate
            });
          }
          return res.end(feed.xml());
        } else {
          return res.render('errors/404', {
            err: "Page not found"
          });
        }
      } else {
        console.log("Error (rss): " + err);
        return res.end(JSON.stringify(err));
      }
    });
  };

}).call(this);
