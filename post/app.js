// Generated by CoffeeScript 1.6.3
(function() {
  var RedisStore, app, articles, auth, cluster, cpu, cpus, express, http, issues, moment, path, photos, rss, sections, setup, staff, users, _i;

  cluster = require('cluster');

  if (cluster.isMaster) {
    console.log("V2 running in a " + (process.env.NODE_ENV ? '`' + process.env.NODE_ENV + '`' : 'production') + " environment.");
    if (process.env.NODE_ENV === 'setup') {
      console.log('Starting setup process.');
      express = require('express');
      setup = require('./routes/setup');
      app = express();
      app.configure('setup', function() {
        return setup(function(resp) {
          console.log(resp);
          return process.kill(process.pid, "SIGTERM");
        });
      });
    } else {
      cpus = require('os').cpus().length;
      for (cpu = _i = 0; 0 <= cpus ? _i < cpus : _i > cpus; cpu = 0 <= cpus ? ++_i : --_i) {
        cluster.fork();
      }
      cluster.on('exit', function(worker) {
        console.log("Worker " + worker.id + " died :(");
        return cluster.fork();
      });
    }
  } else if (process.env.NODE_ENV !== 'setup') {
    express = require('express');
    http = require('http');
    moment = require('moment');
    path = require('path');
    RedisStore = require('connect-redis')(express);
    articles = require('./routes/articles');
    auth = require('./routes/auth');
    issues = require('./routes/issues');
    rss = require('./routes/rss');
    sections = require('./routes/sections');
    users = require('./routes/users');
    photos = require('./routes/photos');
    staff = [];
    staff.articles = require('./routes/staff/articles');
    app = express();
    app.configure(function() {
      app.use(express.cookieParser('***REMOVED***'));
      app.use(express["static"](path.join(__dirname, 'public')));
      app.use(express.favicon(path.join(__dirname, 'public/images/favicon.ico')));
      app.use(express.bodyParser());
      app.use(express.session({
        store: new RedisStore,
        secret: '***REMOVED***'
      }));
      moment.lang('en', {
        monthsShort: ["Jan.", "Feb.", "March", "April", "May", "June", "July", "Aug.", "Sept.", "Oct.", "Nov.", "Dec."]
      });
      app.set('views', __dirname + '/views');
      app.set('view engine', 'jade');
      app.disable('x-powered-by');
      app.set('port', process.env.PORT || 8000);
      app.use(app.router);
      app.use(express.csrf());
      return true;
    });
    /*
    	Update this stuff
    */

    app.get('/', articles.index);
    app.get('/articles/:slug', auth.optionalLogin, articles.view);
    /*
    	/Update this stuff
    */

    app.get('/issues/current', function(req, res, next) {
      return res.redirect('https://s3.amazonaws.com/torch_issues/' + (moment() < moment("2014-4-17") ? 'march_2014' : 'april_2014') + '.pdf');
    });
    app.get('/login', auth.login_get);
    app.post('/login', auth.login_post);
    app.get('/logout', auth.logout);
    app.get('/rss', rss);
    app.get('/sections/:slug', sections.view);
    /*
    	Staff Stuff
    */

    app.get('/staff', auth.requireStaff, function(req, res, next) {
      return res.render('staff');
    });
    app.get('/staff/articles/', auth.requireStaff, staff.articles.index);
    app.get('/staff/articles/new', auth.requireStaff, articles.new_get);
    app.post('/staff/articles/new', auth.requireStaff, articles.new_post);
    app.get('/staff/articles/:slug', auth.requireStaff, articles.view);
    app.post('/staff/articles/:slug/comment', auth.requireStaff, articles.comment);
    app.get('/staff/articles/:slug/edit', auth.requireStaff, articles.edit_get);
    app.post('/staff/articles/:slug/edit', auth.requireStaff, articles.edit_post);
    app.post('/staff/articles/:slug/delete', auth.requireStaff, articles.remove);
    app.post('/staff/articles/:slug/photosDelete', auth.requireStaff, articles.removePhotos);
    app.get('/staff/articles/:slug/photos/upload', auth.requireStaff, photos.view);
    app.get("/staff/articles/:slug/photos/upload/signS3/:mime(\\w+\/\\w+)/:filename", auth.requireStaff, photos.auth);
    app.get("/staff/articles/:slug/photos/upload/confirmed/:name", auth.requireStaff, photos.addToDB);
    app.get('/staff/issues', auth.requireStaff, issues.list);
    app.get('/staff/issues/new', auth.requireStaff, issues.new_get);
    app.post('/staff/issues/new', auth.requireStaff, issues.new_post);
    app.get('/staff/issues/:slug', auth.requireStaff, issues.edit_get);
    app.post('/staff/issues/:slug', auth.requireStaff, issues.edit_post);
    app.get('/staff/sections', auth.requireStaff, sections.list);
    app.get('/staff/sections/new', auth.requireStaff, sections.new_get);
    app.post('/staff/sections/new', auth.requireStaff, sections.new_post);
    app.get('/staff/sections/:slug', auth.requireStaff, sections.edit_get);
    app.post('/staff/sections/:slug', auth.requireStaff, sections.edit_post);
    app.get('/staff/sections/:slug/delete', auth.requireStaff, sections.remove);
    app.get('/staff/users', auth.requireStaff, users.list);
    app.get('/staff/users/new', auth.requireStaff, users.new_get);
    app.post('/staff/users/new', auth.requireStaff, users.new_post);
    app.get('/staff/users/:slug', auth.requireStaff, users.edit_get);
    app.post('/staff/users/:slug', auth.requireStaff, users.edit_post);
    app.post('/staff/users/:slug/delete', auth.requireStaff, users.remove);
    /*
    	End Staff Suff
    */

    app.listen(app.get('port'), function() {
      console.log("Express server listening on port " + app.get('port'));
      return console.log("Worker " + cluster.worker.id + " running!");
    });
  } else {
    console.log("Uhh. This should never happen. See app.js.");
  }

}).call(this);
