// Generated by CoffeeScript 1.6.3
(function() {
  var db, findArticle, htmlToText, marked, moment, photo_bucket_name, string;

  db = require('../../db');

  moment = require('moment');

  marked = require('marked');

  string = require('string');

  htmlToText = require('html-to-text');

  photo_bucket_name = "torch_photos";

  marked.setOptions({
    gfm: true,
    breaks: true,
    tables: false,
    sanitize: true
  });

  exports.index = function(req, res, next) {
    return db.Articles.find({}, {
      publishDate: 1,
      body: 1,
      title: 1,
      author: 1,
      slug: 1,
      photos: 1,
      status: 1,
      createdDate: 1
    }).sort({
      'createdDate': -1
    }).limit(30).execFind(function(err, recent) {
      var article, i, recentAr, _i, _len;
      if (!err) {
        if (recent.length && (recent != null)) {
          recentAr = [];
          for (i = _i = 0, _len = recent.length; _i < _len; i = ++_i) {
            article = recent[i];
            recentAr[i] = {
              body: string(htmlToText.fromString(article.body[0].body)).truncate(250).s,
              author: article.author,
              title: string(article.title).truncate(75).s,
              date: {
                human: article.publishDate ? moment(article.publishDate).format("MMM D, YYYY") : void 0,
                robot: article.publishDate ? moment(article.publishDate).toISOString().split('T')[0] : void 0
              },
              slug: "/staff/articles/" + article.slug + "/",
              section: JSON.stringify(article.section),
              photo: article.photos[0] ? "http://s3.amazonaws.com/" + photo_bucket_name + "/" + article._id + "/" + article.photos[0].name : void 0,
              isPublished: article.status === 4 && article.publishDate ? (moment(article.publishDate) < moment() ? 2 : 1) : 0,
              isRotatable: article.photos[0] ? true : false
            };
          }
          return res.render('index', {
            recentAr: recentAr,
            isStaffView: true
          });
        } else {
          return res.render('errors/404', {
            _err: ["Article not found"]
          });
        }
      } else {
        console.log("Error (staff/articles): " + err);
        return res.end(JSON.stringify(err));
      }
    });
  };

  findArticle = function(slug, update, callback) {
    if (update == null) {
      update = false;
    }
    return db.Articles.findOne({
      slug: slug
    }).select({
      publishDate: 1,
      body: 1,
      title: 1,
      author: 1,
      bodyType: 1,
      lockHTML: 1,
      status: 1,
      publication: 1,
      approvedBy: 1,
      staffComments: 1,
      views: 1,
      slug: 1,
      photos: 1,
      section: 1
    }).exec(function(err, resp) {
      if (update) {
        resp.views++;
        return resp.save(callback(err, resp));
      } else {
        return callback(err, resp);
      }
    });
  };

}).call(this);
