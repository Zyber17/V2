// Generated by CoffeeScript 1.6.2
(function() {
  var db, findArticle, marked, moment, string;

  db = require('../db');

  moment = require('moment');

  marked = require('marked');

  string = require('string');

  marked.setOptions({
    gfm: true,
    breaks: true,
    tables: false,
    sanitize: true
  });

  exports.index = function(req, res, next) {
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
    }).sort('-publishDate').limit(10).execFind(function(err, resp) {
      var article, articles, i, _i, _len;

      articles = [];
      for (i = _i = 0, _len = resp.length; _i < _len; i = ++_i) {
        article = resp[i];
        articles[i] = {
          body: string(article.body[0].body).truncate(250).s,
          author: article.author,
          title: article.title,
          date: moment(article.publishDate).format("MMMM D, YYYY"),
          exactDate: moment(article.publishDate).toISOString().split('T')[0],
          slug: "/articles/" + article.slug + "/"
        };
      }
      return res.render('index', {
        articles: articles
      });
    });
  };

  exports.new_get = function(req, res, next) {
    var issues, sections;

    sections = [
      {
        _id: 'jkdf33',
        name: 'Studient Life'
      }, {
        _id: 'ieuhrg76',
        name: 'Science'
      }
    ];
    issues = {
      0: [
        {
          _id: 'sdsdv',
          name: 'July 2012'
        }
      ],
      1: [
        {
          _id: 'sdsdv',
          name: 'March 2012'
        }
      ],
      2: [
        {
          name: 'Web'
        }
      ]
    };
    if (req.session.message) {
      req.session.message.sections = sections;
      req.session.message.issues = issues;
      res.render('edit', req.session.message);
      return req.session.message = null;
    } else {
      return res.render('edit', {
        knowsHTML: false,
        sections: sections,
        issues: issues
      });
    }
  };

  exports.new_post = function(req, res, next) {
    var err, newArticle;

    err = [];
    if (!req.body.body || req.body.body.length < 3) {
      err.push('Article must be longer than three characters.');
    }
    if (!req.body.title || req.body.title.length < 3) {
      err.push('Title must be longer than three characters.');
    }
    if (!req.body.author || req.body.author.length < 3) {
      err.push('Author’s name must be longer than three characters.');
    }
    if (err.length > 0) {
      req.session.message = req.body;
      req.session.message._err = err;
      req.session.message.selectedIssue = req.body.issue;
      req.session.message.selectedSection = req.body.section;
      req.session.message.approval = {
        advisor: req.body.advisorapproval || 0,
        administration: req.body.administrationapproval || 0
      };
      return res.redirect('/');
    } else {
      newArticle = new db.Articles({
        title: req.body.title,
        author: req.body.author,
        publishDate: req.body.date ? moment(req.body.date, "MM-DD-YYYY").toDate() : void 0,
        lockHTML: string(req.body.lockHTML).toBoolean(),
        createdDate: moment().toDate(),
        status: req.body.status,
        publication: req.body.publication,
        approvedBy: {
          advisor: req.body.advisorapproval || 0,
          administration: req.body.administrationapproval || 0
        }
      });
      newArticle.body.unshift({
        body: req.body.body,
        editor: req.body.author,
        editDate: moment().toDate()
      });
      return newArticle.save(function(err, resp) {
        if (err === null) {
          res.redirect("/articles/" + resp.slug + "/");
        } else {
          console.log("Error (articles): " + err);
        }
        return res.end(JSON.stringify(err));
      });
    }
  };

  exports.view = function(req, res, next) {
    var update;

    update = true;
    return findArticle(req.params.slug, update, function(err, resp) {
      var comment, comments, i, now, options, revbody, revision, versions, _i, _j, _len, _len1, _ref, _ref1;

      if (!err) {
        if (resp) {
          versions = [];
          now = moment();
          revbody = resp.body.slice();
          _ref = revbody.reverse();
          for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
            revision = _ref[i];
            versions[i] = {
              ago: moment.duration(moment(revision.editDate).diff(now, 'milliseconds'), 'milliseconds').humanize(true),
              editor: revision.editor,
              num: i + 1
            };
          }
          comments = [];
          _ref1 = resp.staffComments;
          for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
            comment = _ref1[i];
            comments[i] = {
              ago: moment.duration(moment(comment.createdDate).diff(now, 'milliseconds'), 'milliseconds').humanize(true),
              exactDate: moment(revision.createdDate).toISOString(),
              author: comment.author,
              body: comment.body,
              edited: comment.edited
            };
          }
          options = {
            body: resp.body[0].body,
            versions: versions.reverse(),
            resp: resp,
            msg: '',
            title: resp.title,
            staff: true,
            comments: comments
          };
          if (resp.publishDate) {
            options.resp.date = moment(resp.publishDate).format("MMMM D, YYYY");
          } else {
            options.resp.date = null;
          }
          if (options.resp.date && options.resp.date < moment()) {
            return res.render('article', options);
          } else {
            if (true) {
              options.msg = "This article is not yet released, you’re seeing it because you’" + (true ? "re on staff" : "ve been granted early access") + ".";
              return res.render('article', options);
            } else {
              return res.render('errors/404', {
                err: "Article not found"
              });
            }
          }
        } else {
          return res.render('errors/404', {
            err: "Article not found"
          });
        }
      } else {
        console.log("Error (articles): " + err);
        return res.end(JSON.stringify(err));
      }
    });
  };

  exports.comment = function(req, res, next) {
    return findArticle(req.params.slug, false, function(err, resp) {
      if (!err) {
        if (resp) {
          resp.staffComments.push({
            body: {
              notRendered: req.body.body,
              rendered: marked(req.body.body)
            },
            author: req.body.author,
            edited: string(req.body.edited).toBoolean(),
            createdDate: moment().toDate()
          });
          return resp.save(function(err, resp) {
            if (err) {
              return res.end(JSON.stringify(err));
            } else {
              return res.redirect("/articles/" + resp.slug + "/");
            }
          });
        } else {
          return res.render('errors/404', {
            err: "Article not found"
          });
        }
      } else {
        console.log("Error (articles): " + err);
        return res.end(JSON.stringify(err));
      }
    });
  };

  exports.edit_get = function(req, res, next) {
    var issues, sections;

    sections = [
      {
        _id: 'jkdf33',
        name: 'Studient Life'
      }, {
        _id: 'ieuhrg76',
        name: 'Science'
      }
    ];
    issues = {
      torch: [
        {
          _id: 'sdsdv',
          name: 'July 2012'
        }
      ],
      match: [
        {
          _id: 'sdsdv',
          name: 'March 2012'
        }
      ]
    };
    if (req.session.message) {
      req.session.message.sections = sections;
      req.session.message.issues = issues;
      res.render('edit', req.session.message);
      return req.session.message = null;
    } else {
      return findArticle(req.params.slug, false, function(err, resp) {
        var content;

        if (!err) {
          if (resp) {
            content = {
              title: resp.title,
              author: resp.author,
              body: resp.body[0].body,
              date: resp.publishDate ? moment(resp.publishDate).format("MM-DD-YYYY") : void 0,
              issue: resp.issue,
              section: resp.section,
              publication: resp.publication,
              knowsHTML: true,
              lockHTML: resp.lockHTML,
              editing: true,
              sections: sections,
              issues: issues,
              status: resp.status || 0,
              approval: {
                advisor: resp.approvedBy.advisor || 0,
                administration: resp.approvedBy.administration || 0
              }
            };
            return res.render('edit', content);
          } else {
            return res.render('errors/404', {
              err: "Article not found"
            });
          }
        } else {
          console.log("Error (articles): " + err);
          return res.end(JSON.stringify(err));
        }
      });
    }
  };

  exports.edit_post = function(req, res, next) {
    var err;

    err = [];
    if (!req.body.body || req.body.body.length < 3) {
      err.push('Article must be longer than three characters.');
    }
    if (!req.body.title || req.body.title.length < 3) {
      err.push('Title must be longer than three characters.');
    }
    if (!req.body.author || req.body.author.length < 3) {
      err.push('Author’s name must be longer than three characters.');
    }
    if (err.length > 0) {
      req.session.message = req.body;
      req.session.message._err = err;
      req.session.message.selectedIssue = req.body.issue;
      req.session.message.selectedSection = req.body.section;
      req.session.message.approval = {
        advisor: req.body.advisorapproval || 0,
        administration: req.body.administrationapproval || 0
      };
      return res.redirect("/articles/" + req.params.slug + "/edit");
    } else {
      return findArticle(req.params.slug, false, function(err, resp) {
        if (!err) {
          if (resp) {
            resp.title = req.body.title;
            resp.author = req.body.author;
            resp.publishDate = req.body.date ? moment(req.body.date, "MM-DD-YYYY").toDate() : void 0;
            resp.issue = req.body.issue;
            resp.section = req.body.section;
            resp.status = req.body.status;
            resp.publication = req.body.publication;
            resp.approvedBy = {
              advisor: req.body.advisorapproval || resp.approvedBy.advisor || 0,
              administration: req.body.administrationapproval || resp.approvedBy.administration || 0
            };
            if (resp.body[0].body !== req.body.body) {
              resp.body.unshift({
                body: req.body.body,
                editor: req.body.author,
                editDate: moment().toDate()
              });
            }
            return resp.save(function(err, resp) {
              if (err) {
                return res.end(JSON.stringify(err));
              } else {
                return res.redirect("/articles/" + resp.slug + "/");
              }
            });
          } else {
            return res.render('errors/404', {
              err: "Article not found"
            });
          }
        } else {
          console.log("Error (articles): " + err);
          return res.end(JSON.stringify(err));
        }
      });
    }
  };

  exports.remove = function(req, res, next) {
    if (req.body["delete"] === "true") {
      return db.Articles.findOneAndRemove({
        slug: req.params.slug
      }, function(err, resp) {
        if (!err) {
          return res.redirect('/');
        } else {
          console.log("Error (articles): " + err);
          return res.end(JSON.stringify(err));
        }
      });
    } else {
      return res.redirect("/articles/" + resp.slug + "/");
    }
  };

  findArticle = function(slug, update, callback) {
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
      slug: 1
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
