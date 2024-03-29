// Generated by CoffeeScript 1.6.3
(function() {
  var db, findSection, moment, photo_bucket_name, string;

  db = require('../db');

  moment = require('moment');

  string = require('string');

  photo_bucket_name = process.env.NODE_ENV === 'dev' ? 'torch_test' : 'torch_photos';

  exports.view = function(req, res, next) {
    return db.Articles.find({
      publishDate: {
        $lte: moment().toDate()
      },
      status: 4,
      'section.slug': req.params.slug
    }, {
      publishDate: 1,
      bodyPlain: 1,
      title: 1,
      author: 1,
      slug: 1,
      photos: 1,
      section: 1
    }).sort({
      'publishDate': -1,
      'lastEditDate': -1
    }).limit(6).execFind(function(err, recent) {
      var article, i, recentAr, _i, _len;
      if (!err) {
        if (recent.length) {
          recentAr = [];
          for (i = _i = 0, _len = recent.length; _i < _len; i = ++_i) {
            article = recent[i];
            recentAr[i] = {
              body: string(article.bodyPlain).truncate(250).s,
              author: article.author,
              title: string(article.title).truncate(75).s,
              date: {
                human: moment(article.publishDate).format("MMM D, YYYY"),
                robot: moment(article.publishDate).toISOString().split('T')[0]
              },
              slug: "/articles/" + article.slug + "/",
              section: JSON.stringify(article.section),
              photo: article.photos[0] ? "http://s3.amazonaws.com/" + photo_bucket_name + "/" + article._id + "/" + article.photos[0].name : void 0,
              rotator: article.photos[0] ? "http://s3.amazonaws.com/" + photo_bucket_name + "/" + article._id + "/" + article.photos[article.photos.length - 1].name : void 0,
              isPublished: 2,
              isRotatable: article.photos[0] ? true : false
            };
          }
          return res.render('articleList', {
            recentAr: recentAr,
            section: recent[0].section.title
          });
        } else {
          return res.render('errors/404', {
            _err: "This section does not have any articles"
          });
        }
      } else {
        console.log("Error (articles): " + err);
        return res.end(JSON.stringify(err));
      }
    });
  };

  findSection = function(slug, callback) {
    return db.Sections.findOne({
      slug: slug
    }).select({
      title: 1,
      slug: 1
    }).exec(function(err, resp) {
      return callback(err, resp);
    });
  };

}).call(this);
