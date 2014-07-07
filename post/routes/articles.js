// Generated by CoffeeScript 1.6.3
(function() {
  var db, findArticle, findSection, htmlToText, marked, moment, photo_bucket_name, photo_bucket_url, string;

  db = require('../db');

  moment = require('moment');

  marked = require('marked');

  string = require('string');

  htmlToText = require('html-to-text');

  photo_bucket_name = process.env.NODE_ENV === 'dev' ? 'torch_test' : "torch_photos";

  photo_bucket_url = "http://s3.amazonaws.com/" + photo_bucket_name + "/";

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
      bodyPlain: 1,
      title: 1,
      author: 1,
      slug: 1,
      photos: 1
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
              body: string(article.bodyPlain).truncate(400),
              author: article.author,
              title: string(article.title).truncate(75).s,
              date: {
                human: moment(article.publishDate).format("MMM D, YYYY"),
                robot: moment(article.publishDate).toISOString().split('T')[0]
              },
              slug: "/articles/" + article.slug + "/",
              section: JSON.stringify(article.section),
              photo: article.photos[0] ? photo_bucket_url + article._id + '/' + (article.photos.length > 1 ? article.photos[article.photos.length - 2].name : article.photos[0].name) : void 0,
              rotator: article.photos[0] ? photo_bucket_url + article._id + '/' + article.photos[article.photos.length - 1].name : void 0,
              isPublished: 2,
              isRotatable: article.photos[0] ? true : false
            };
          }
          return res.render('index', {
            recentAr: recentAr
          });
        } else {
          return res.render('errors/404', {
            _err: ["Article not found"]
          });
        }
      } else {
        console.log("Error (articles): " + err);
        return res.end(JSON.stringify(err));
      }
    });
  };

  exports.json = function(req, res, next) {
    exports.index = function(req, res, next) {};
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
      slug: 1,
      photos: 1,
      _id: 0
    }).sort({
      'publishDate': -1,
      'lastEditDate': -1
    }).limit(6).execFind(function(err, recent) {
      var article, i, _i, _len;
      if (!err) {
        if (recent.length) {
          for (i = _i = 0, _len = recent.length; _i < _len; i = ++_i) {
            article = recent[i];
            recent[i].body.slice(0);
          }
          return res.json(recent);
        } else {
          return res.render('errors/404', {
            _err: ["Article not found"]
          });
        }
      } else {
        console.log("Error (articles): " + err);
        return res.end(JSON.stringify(err));
      }
    });
  };

  exports.new_get = function(req, res, next) {
    return db.Sections.find().select({
      title: 1,
      slug: 1
    }).exec(function(err, resp) {
      if (req.session.message) {
        req.session.message.sections = resp;
        res.render('edit', req.session.message);
        return req.session.message = null;
      } else {
        return res.render('edit', {
          knowsHTML: false,
          sections: resp,
          author: req.session.user.name
        });
      }
    });
  };

  exports.new_post = function(req, res, next) {
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
      return res.redirect('/');
    } else {
      return findSection(req.body.section, function(err, resp) {
        var newArticle;
        if (!err) {
          if (resp) {
            newArticle = new db.Articles({
              title: req.body.title,
              section: {
                title: resp.title,
                slug: resp.slug,
                id: resp._id
              },
              bodyPlain: htmlToText.fromString(req.body.body),
              author: req.body.author,
              publishDate: req.body.date ? moment(req.body.date, "MM-DD-YYYY").toDate() : void 0,
              lastEditDate: moment().toDate(),
              lockHTML: string(req.body.lockHTML).toBoolean(),
              createdDate: moment().toDate(),
              status: req.body.status,
              publication: 2,
              approvedBy: {
                advisor: req.body.advisorapproval || 0,
                administration: req.body.administrationapproval || 0
              },
              isGallery: req.body.isGallery,
              isVideo: req.body.isVideo,
              videoEmebed: req.body.videoEmebed ? req.body.videoEmebed : ''
            });
            newArticle.body.unshift({
              body: req.body.body,
              editor: req.session.user.name,
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
          } else {
            return res.render('errors/404', {
              err: "Section not found"
            });
          }
        } else {
          console.log("Error (articles): " + err);
          return res.end(JSON.stringify(err));
        }
      });
    }
  };

  exports.view = function(req, res, next) {
    var update;
    update = true;
    if (req.session.isUser === true) {
      update = false;
    }
    return findArticle(req.params.slug, update, function(err, resp) {
      var comment, comments, galleryUrls, i, isGallery, now, options, photo, revbody, revision, versions, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      res.end('hi');
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
          isGallery = resp.isGallery && resp.photos[0] ? true : false;
          if (isGallery) {
            galleryUrls = [];
            _ref2 = resp.photos;
            for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
              photo = _ref2[_k];
              galleryUrls.push(photo_bucket_url + resp._id + '/' + photo.name);
            }
          }
          options = {
            body: resp.body[0].body,
            versions: versions.reverse(),
            resp: resp,
            date: {
              human: resp.publishDate ? moment(resp.publishDate).format("MMM D, YYYY") : void 0,
              robot: resp.publishDate ? moment(resp.publishDate).toISOString().split('T')[0] : void 0
            },
            msg: null,
            title: resp.title,
            staff: req.session.isStaff || false,
            comments: comments,
            photo: resp.photos[0] ? photo_bucket_url + resp._id + '/' + (resp.photos.length > 1 ? resp.photos[resp.photos.length - 2].name : resp.photos[0].name) : void 0,
            section: resp.section,
            isGallery: isGallery ? resp.isGallery : false,
            galleryItems: isGallery ? galleryUrls : null,
            isVideo: resp.isVideo ? resp.isVideo : false,
            videoEmebed: resp.videoEmebed ? resp.videoEmebed : null
          };
          if (resp.publishDate) {
            options.resp.date = moment(resp.publishDate).format("MMMM D, YYYY");
          } else {
            options.resp.date = null;
          }
          if (resp.publishDate && moment(resp.publishDate) < moment()) {
            return res.render('article', options);
          } else {
            if (req.session.isUser) {
              options.msg = "This article is not yet released, you’re seeing it because you’" + (req.session.user.isStaff ? "re on staff" : "ve been granted early access") + ".";
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
              return res.redirect("/staff/articles/" + resp.slug + "/");
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
    return db.Sections.find().select({
      title: 1,
      slug: 1
    }).exec(function(err, sections) {
      req.session.message = null;
      if (req.session.message) {
        req.session.message.sections = sections;
        return res.render('edit', req.session.message);
      } else {
        return findArticle(req.params.slug, false, function(err, article) {
          var content;
          if (!err) {
            if (article) {
              content = {
                title: article.title,
                author: article.author,
                body: article.body[0].body,
                date: article.publishDate ? moment(article.publishDate).format("MM-DD-YYYY") : void 0,
                issue: article.issue,
                section: article.section,
                publication: article.publication,
                knowsHTML: false,
                lockHTML: article.lockHTML,
                editing: true,
                sections: sections,
                isGallery: article.isGallery,
                isVideo: article.isVideo,
                videoEmebed: article.videoEmebed,
                status: article.status || 0,
                approval: {
                  advisor: article.approvedBy.advisor || 0,
                  administration: article.approvedBy.administration || 0
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
    });
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
            return findSection(req.body.section, function(err, section_resp) {
              if (!err) {
                if (resp) {
                  resp.title = req.body.title;
                  resp.author = req.body.author;
                  resp.bodyPlain = htmlToText.fromString(req.body.body);
                  resp.publishDate = req.body.date ? moment(req.body.date, "MM-DD-YYYY").toDate() : void 0;
                  resp.issue = req.body.issue;
                  resp.status = req.body.status;
                  resp.publication = req.body.publication;
                  resp.lastEditDate = moment().toDate();
                  resp.isGallery = req.body.isGallery;
                  resp.isVideo = req.body.isVideo;
                  resp.videoEmebed = req.body.videoEmebed ? req.body.videoEmebed : '';
                  resp.section = {
                    title: section_resp.title,
                    slug: section_resp.slug,
                    id: section_resp._id
                  };
                  resp.approvedBy = {
                    advisor: req.body.advisorapproval || resp.approvedBy.advisor || 0,
                    administration: req.body.administrationapproval || resp.approvedBy.administration || 0
                  };
                  if (resp.body[0].body !== req.body.body) {
                    resp.body.unshift({
                      body: req.body.body,
                      editor: req.session.user.name,
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
                    err: "Section not found"
                  });
                }
              } else {
                console.log("Error (articles): " + err);
                return res.end(JSON.stringify(err));
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
          return res.redirect('/staff/articles/');
        } else {
          console.log("Error (articles): " + err);
          return res.end(JSON.stringify(err));
        }
      });
    } else {
      return res.redirect("/articles/" + resp.slug + "/");
    }
  };

  exports.removePhotos = function(req, res, next) {
    if (req.body.photosDelete === "true") {
      return db.Articles.findOne({
        slug: req.params.slug
      }, function(err, resp) {
        if (!err) {
          if (resp) {
            resp.photos = [];
            return resp.save(function(err, resp) {
              if (!err) {
                return res.redirect("/staff/articles/" + resp.slug + "/");
              } else {
                console.log("Error (articles): " + err);
                return res.end(JSON.stringify(err));
              }
            });
          } else {
            return res.render('errors/404', {
              err: "Not found"
            });
          }
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
    if (update == null) {
      update = false;
    }
    return db.Articles.findOne({
      slug: slug
    }).select({
      publishDate: 1,
      body: 1,
      bodyPlain: 1,
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
      section: 1,
      isGallery: 1,
      isVideo: 1,
      videoEmebed: 1
    }).exec(function(err, resp) {
      if (update) {
        resp.views++;
        return resp.save(callback(err, resp));
      } else {
        return callback(err, resp);
      }
    });
  };

  findSection = function(id, callback) {
    return db.Sections.findOne({
      _id: id
    }).select({
      title: 1,
      slug: 1
    }).exec(function(err, resp) {
      return callback(err, resp);
    });
  };

}).call(this);
