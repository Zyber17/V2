// Generated by CoffeeScript 1.6.2
(function() {
  var db, findIssue, moment;

  db = require('../db');

  moment = require('moment');

  exports.list = function(req, res, next) {
    return db.Issues.find({}, {
      publishDate: 1,
      title: 1,
      publication: 1,
      slug: 1
    }).sort('-createdDate').execFind(function(err, resp) {
      var i, issue, issues, _i, _len;

      if (!err) {
        issues = [];
        for (i = _i = 0, _len = resp.length; _i < _len; i = ++_i) {
          issue = resp[i];
          issues[i] = {
            title: issue.title,
            date: moment(issue.publishDate).format("MMMM D, YYYY"),
            exactDate: moment(issue.publishDate).toISOString().split('T')[0],
            slug: "/issues/" + issue.slug + "/",
            publication: issue.publication
          };
        }
        return res.render('issuesList', {
          issues: issues
        });
      } else {
        console.log(err);
        return res.end(JSON.stringify(err));
      }
    });
  };

  exports.new_get = function(req, res, next) {
    var send;

    if (req.session.message) {
      send = {
        err: req.session.message.err,
        title: req.session.message.content.title,
        publication: req.session.message.content.publication,
        date: req.session.message.content.date,
        editing: false
      };
      return res.render('newIssue', send);
    } else {
      return res.render('newIssue', {
        editing: false
      });
    }
  };

  exports.new_post = function(req, res, next) {
    var err, newIssue;

    err = [];
    if (!req.body.date) {
      err.push("Date must be set.");
    }
    if (!req.body.title || req.body.title.length < 3) {
      err.push("Name must be three characters or more.");
    }
    if (err.length > 0) {
      req.session.message({
        err: err,
        content: req.body
      });
      return res.redirect('/issues/new');
    } else {
      newIssue = new db.Issues({
        title: req.body.title,
        publication: req.body.publication,
        publishDate: moment(req.body.date, "MM-DD-YYYY").toDate(),
        createdDate: moment().toDate()
      });
      return newIssue.save(function(err, resp) {
        if (!err) {
          return res.redirect('/issues/');
        } else {
          return res.end(JSON.stringify(err));
        }
      });
    }
  };

  exports.edit_get = function(req, res, next) {
    var send;

    if (req.session.message) {
      send = {
        err: req.session.message.err,
        title: req.session.message.content.title,
        publication: req.session.message.content.publication,
        date: req.session.message.content.date,
        editing: true
      };
      return res.render('newIssue', send);
    } else {
      return findIssue(req.params.slug, function(err, resp) {
        if (!err) {
          if (resp) {
            send = {
              title: resp.title,
              publication: resp.publication,
              date: moment(resp.publishDate).format("MM-DD-YYYY"),
              editing: true
            };
            return res.render('newIssue', send);
          } else {
            return res.render('errors/404', {
              err: "Issue not found"
            });
          }
        } else {
          console.log(err);
          return res.end(JSON.stringify(err));
        }
      });
    }
  };

  exports.edit_post = function(req, res, next) {
    var err;

    err = [];
    if (!req.body.date) {
      err.push("Date must be set.");
    }
    if (!req.body.title || req.body.title.length < 3) {
      err.push("Name must be three characters or more.");
    }
    if (err.length > 0) {
      req.session.message({
        err: err,
        content: req.body
      });
      return res.redirect("/issues/" + req.params.slug);
    } else {
      return findIssue(req.params.slug, function(err, resp) {
        if (!err) {
          if (resp) {
            resp.title = req.body.title;
            resp.date = moment(req.body.date, "MM-DD-YYYY").toDate();
            resp.publication = req.body.publication;
            return resp.save(function(err, resp) {
              if (err) {
                return res.end(JSON.stringify(err));
              } else {
                return res.redirect("/issues/");
              }
            });
          } else {
            return res.render('errors/404', {
              err: "Article not found"
            });
          }
        } else {
          console.log(err);
          return res.end(JSON.stringify(err));
        }
      });
    }
  };

  findIssue = function(slug, callback) {
    return db.Issues.findOne({
      slug: slug
    }).select({
      publishDate: 1,
      title: 1,
      publication: 1,
      slug: 1
    }).exec(function(err, resp) {
      return callback(err, resp);
    });
  };

}).call(this);