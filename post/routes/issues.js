// Generated by CoffeeScript 1.6.3
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
            slug: "/staff/issues/" + issue.slug + "/",
            publication: issue.publication
          };
        }
        return res.render('issuesList', {
          issues: issues
        });
      } else {
        console.log("Error (issues): " + err);
        return res.end(JSON.stringify(err));
      }
    });
  };

  exports.new_get = function(req, res, next) {
    if (req.session.message) {
      req.session.message.editing = false;
      res.render('newIssue', req.session.message);
      return req.session.message = null;
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
      req.session.message = req.body;
      req.session.message.err = _err;
      return res.redirect('/staff/issues/new');
    } else {
      newIssue = new db.Issues({
        title: req.body.title,
        publication: req.body.publication,
        publishDate: moment(req.body.date, "MM-DD-YYYY").toDate(),
        createdDate: moment().toDate()
      });
      return newIssue.save(function(err, resp) {
        if (!err) {
          return res.redirect('/staff/issues/');
        } else {
          console.log("Error (issues): " + err);
          return res.end(JSON.stringify(err));
        }
      });
    }
  };

  exports.edit_get = function(req, res, next) {
    if (req.session.message) {
      req.session.message.editing = true;
      res.render('newIssue', req.session.message);
      return req.session.message = null;
    } else {
      return findIssue(req.params.slug, function(err, resp) {
        var send;
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
          console.log("Error (issues): " + err);
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
      req.session.message = req.body;
      req.session.message.err = _err;
      return res.redirect("/staff/issues/" + req.params.slug);
    } else {
      return findIssue(req.params.slug, function(err, resp) {
        if (!err) {
          if (resp) {
            resp.title = req.body.title;
            resp.date = moment(req.body.date, "MM-DD-YYYY").toDate();
            resp.publication = req.body.publication;
            return resp.save(function(err, resp) {
              if (err) {
                console.log("Error (issues): " + err);
                return res.end(JSON.stringify(err));
              } else {
                return res.redirect("/staff/issues/");
              }
            });
          } else {
            return res.render('errors/404', {
              err: "Article not found"
            });
          }
        } else {
          console.log("Error (issues): " + err);
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
