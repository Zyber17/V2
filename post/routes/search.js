// Generated by CoffeeScript 1.6.3
(function() {
  var db, es, htmlToText, marked, moment, photo_bucket_name, photo_bucket_url, searchGet, searchView, string;

  db = require('../db');

  es = require('../es');

  moment = require('moment');

  marked = require('marked');

  string = require('string');

  htmlToText = require('html-to-text');

  photo_bucket_name = process.env.NODE_ENV === 'dev' ? 'torch_test' : "torch_photos";

  photo_bucket_url = "http://s3.amazonaws.com/" + photo_bucket_name + "/";

  exports.searchDirector = function(req, res, next) {
    if (req.query.q != null) {
      return searchGet(req, res, next);
    } else {
      return searchView(req, res, next);
    }
  };

  searchView = function(req, res, next) {
    return res.render('search');
  };

  searchGet = function(req, res, next) {
    var query2;
    query2 = decodeURIComponent(req.query.q);
    return es.search({
      index: 'torch',
      type: 'article',
      q: query2
    }, function(err, resp) {
      if (!err) {
        return res.end(JSON.stringify(resp));
      } else {
        return console.log(JSON.stringify(err));
      }
    });
  };

}).call(this);