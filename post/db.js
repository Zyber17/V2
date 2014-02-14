// Generated by CoffeeScript 1.6.3
(function() {
  var ObjectId, Schema, articleBodies, articles, bcrypt, database, issues, mongoose, monguurl, photos, saltWorkFactor, sections, users;

  mongoose = require('mongoose');

  monguurl = require('monguurl');

  bcrypt = require('bcrypt');

  Schema = mongoose.Schema;

  ObjectId = Schema.ObjectId;

  saltWorkFactor = 10;

  mongoose.connect('localhost', 'jffffudfff');

  database = mongoose.connection;

  database.on('error', console.error.bind(console, 'connection error:'));

  database.on('open', function() {
    return console.log("Mongoose and Mongo are working");
  });

  users = new Schema({
    name: {
      type: String,
      required: true,
      index: {
        unique: true
      }
    },
    username: {
      type: String,
      required: true,
      unique: true
    },
    isStaff: {
      type: Boolean,
      "default": true,
      required: true
    },
    email: {
      type: String,
      unique: true
    },
    bio: {
      rendered: {
        type: String
      },
      notRendered: {
        type: String
      }
    },
    password: {
      type: String,
      required: true
    },
    slug: {
      type: String
    },
    permissions: {
      knowsHTML: {
        type: Boolean,
        "default": false
      },
      canPublishStories: {
        type: Boolean,
        "default": true
      },
      canDeletePhotos: {
        type: Boolean,
        "default": true
      },
      canManageIssues: {
        type: Boolean,
        "default": false
      },
      canManageUsers: {
        type: Boolean,
        "default": false
      },
      canManageSections: {
        type: Boolean,
        "default": false
      },
      canEditPlannerFormats: {
        type: Boolean,
        "default": false
      },
      canAcceptPlanners: {
        type: Boolean,
        "default": false
      },
      canComment: {
        type: Boolean,
        "default": true
      },
      canEditOthersComments: {
        type: Boolean,
        "default": true
      },
      canChat: {
        type: Boolean,
        "default": true
      },
      accountStatus: {
        isWebmaster: {
          type: Boolean,
          "default": false
        },
        isRetired: {
          type: Boolean,
          "default": false
        },
        isDisabled: {
          type: Boolean,
          "default": false
        }
      }
    }
  });

  users.plugin(monguurl({
    source: 'name',
    target: 'slug'
  }));

  users.pre('save', function(next) {
    var user;
    user = this;
    if (!user.isModified('password')) {
      next();
    }
    return bcrypt.genSalt(saltWorkFactor, function(err, salt) {
      if (err) {
        next(err);
      }
      return bcrypt.hash(user.password, salt, function(err, hash) {
        if (err) {
          next(err);
        }
        user.password = hash;
        return next();
      });
    });
  });

  users.methods.comparePassword = function(candidatePassword, callback) {
    return bcrypt.compare(candidatePassword, this.password, function(err, isMatch) {
      if (err) {
        callback(err);
      }
      return callback(null, isMatch);
    });
  };

  articles = new Schema({
    title: {
      type: String,
      required: true
    },
    slug: {
      type: String,
      index: {
        unique: true
      }
    },
    author: {
      type: String,
      required: true
    },
    lockHTML: {
      type: Boolean,
      "default": false
    },
    body: [articleBodies],
    photos: [photos],
    section: {
      title: {
        type: String,
        required: true
      },
      slug: {
        type: String,
        required: true
      },
      id: {
        type: String,
        required: true
      }
    },
    isGallery: {
      type: Boolean,
      "default": false
    },
    issue: {
      type: Array,
      ref: 'issues'
    },
    publishDate: {
      type: Date,
      "default": null
    },
    lastEditDate: {
      type: Date,
      "default": null
    },
    createdDate: {
      type: Date,
      "default": Date.now
    },
    status: {
      type: Number,
      "default": 0
    },
    approvedBy: {
      advisor: {
        type: Number,
        "default": 0
      },
      administration: {
        type: Number,
        "default": 0
      }
    },
    staffComments: [
      {
        body: {
          rendered: {
            type: String,
            required: true
          },
          notRendered: {
            type: String,
            required: true
          }
        },
        author: {
          type: String
        },
        edited: {
          type: Boolean,
          "default": false
        },
        createdDate: {
          type: Date,
          "default": Date.now
        }
      }
    ],
    views: {
      type: Number,
      "default": 0
    },
    publication: {
      type: Number,
      "default": 0
    }
  });

  articleBodies = new Schema({
    body: {
      type: String,
      required: true
    },
    editor: {
      type: ObjectId,
      ref: 'users'
    },
    editDate: {
      type: Date,
      "default": Date.now
    }
  });

  articles.plugin(monguurl({
    source: 'title',
    target: 'slug'
  }));

  photos = new Schema({
    name: {
      type: Number,
      index: {
        unique: true
      }
    },
    isRotator: {
      type: Boolean,
      "default": false
    },
    isPreview: {
      type: Boolean,
      "default": false
    },
    uploadDate: {
      type: Date,
      required: true
    },
    photographer: {
      type: Date,
      "default": Date.now,
      required: true
    },
    caption: {
      type: String,
      required: true
    },
    slug: {
      type: String,
      index: {
        unique: true
      }
    }
  });

  photos.plugin(monguurl({
    source: 'name',
    target: 'slug'
  }));

  issues = new Schema({
    title: {
      type: String,
      required: true
    },
    slug: {
      type: String,
      index: {
        unique: true
      }
    },
    publication: {
      type: Number,
      "default": 0,
      required: true
    },
    publishDate: {
      type: Date,
      required: true
    },
    createdDate: {
      type: Date,
      "default": Date.now,
      required: true
    },
    download: {
      type: String
    }
  });

  issues.plugin(monguurl({
    source: 'title',
    target: 'slug'
  }));

  sections = new Schema({
    title: {
      type: String,
      required: true
    },
    slug: {
      type: String,
      index: {
        unique: true
      }
    }
  });

  sections.plugin(monguurl({
    source: 'title',
    target: 'slug'
  }));

  module.exports = {
    ObjectId: ObjectId,
    Articles: database.model('articles', articles),
    Issues: database.model('issues', issues),
    Sections: database.model('sections', sections),
    Users: database.model('users', users)
  };

}).call(this);
