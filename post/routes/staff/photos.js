// Generated by CoffeeScript 1.6.3
(function() {
  var createS3Policy, crypto, db, moment;

  db = require('../../db');

  crypto = require('crypto');

  moment = require('moment');

  exports.view = function(req, res, next) {
    return res.render('staff/uploadPhoto');
  };

  exports.auth = function(req, res, next) {
    return createS3Policy(req.params.slug, req.params.mime, req.params.filename, function(err, policy, name) {
      var ret;
      if (!err) {
        ret = {
          policy: policy,
          name: name
        };
        return res.end(JSON.stringify(ret));
      } else {
        console.log("Error (photos): " + err);
        return res.send(403, err);
      }
    });
  };

  createS3Policy = function(slug, mime, name, callback) {
    return db.Articles.findOne({
      slug: slug
    }).exec(function(err, resp) {
      var S3_ACCESS_KEY, S3_BUCKET_NAME, S3_SECRET_KEY, amzHeaders, expires, extension, extention, go, sig, signed_request, stringToSign;
      go = true;
      extention = '';
      switch (mime.toLowerCase()) {
        case 'image/png':
          extension = 'png';
          break;
        case 'image/jpg':
          extension = 'jpg';
          break;
        case 'image/jpeg':
          extension = 'jpeg';
          break;
        case 'image/gif':
          extension = 'gif';
          break;
        default:
          go = false;
      }
      if (go) {
        S3_BUCKET_NAME = 'torch_photos';
        S3_ACCESS_KEY = 'AKIAJ6R3AYRWSSPJEOZQ';
        S3_SECRET_KEY = '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';
        if (process.env.NODE_ENV === 'dev') {
          S3_BUCKET_NAME = 'torch_test';
        }
        name = crypto.createHmac("sha1", S3_SECRET_KEY).update("" + name + ": " + mime + " at " + (new Date().getTime()) + " random is " + (Math.floor(Math.random() * 99999999).toString())).digest("base64").replace('=', '_').replace('/', '__');
        expires = moment().add('minutes', 15).unix();
        amzHeaders = "x-amz-acl:public-read";
        stringToSign = "PUT\n\n" + mime + "\n" + expires + "\n" + amzHeaders + "\n/" + S3_BUCKET_NAME + "/" + resp._id + "/" + name + "." + extension;
        sig = crypto.createHmac("sha1", S3_SECRET_KEY).update(stringToSign).digest("base64");
        signed_request = "https://s3.amazonaws.com/" + S3_BUCKET_NAME + "/" + resp._id + "/" + name + "." + extension + "?AWSAccessKeyId=" + S3_ACCESS_KEY + "&Expires=" + expires + "&Signature=" + (encodeURIComponent(sig));
        return callback(null, signed_request, "" + name + "." + extension);
      } else {
        return callback('Invalid mime', null, null);
      }
    });
  };

  exports.addToDB = function(req, res, next) {
    return db.Articles.findOne({
      slug: req.params.slug
    }).exec(function(err, resp) {
      if (!err) {
        if (resp) {
          resp.photos.unshift({
            name: req.params.name,
            date: moment().toDate(),
            photographer: req.session.user.name
          });
          return resp.save(function(err, resp) {
            if (!err) {
              return res.end('success');
            } else {
              console.log("Error (photos): " + err);
              return res.send(403, err);
            }
          });
        } else {
          return res.render('errors/404', {
            err: "Article not found"
          });
        }
      } else {
        console.log("Error (photos): " + err);
        return res.send(403, err);
      }
    });
  };

}).call(this);