// Generated by CoffeeScript 1.6.3
(function() {
  var RedisStore, app, articles, auth, cluster, cpu, cpus, express, http, moment, path, rss, search, sections, setup, staff, _i;

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
    auth = require('./routes/auth');
    articles = require('./routes/articles');
    search = require('./routes/search');
    rss = require('./routes/rss');
    sections = require('./routes/sections');
    staff = [];
    staff.articles = require('./routes/staff/articles');
    staff.issues = require('./routes/staff/issues');
    staff.photos = require('./routes/staff/photos');
    staff.sections = require('./routes/staff/sections');
    staff.users = require('./routes/staff/users');
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
      app.use(function(req, res, next) {
        return res.render('errors/404', 404);
      });
      app.use(express.csrf());
      return true;
    });
    /*
    	Update this stuff
    */

    app.get('/', articles.index);
    app.get('/articles.json', articles.json);
    app.get('/articles/:slug', auth.optionalLogin, articles.view);
    app.get('/search', search.searchDirector);
    /*
    	/Update this stuff
    */

    app.get('/issues/current', function(req, res, next) {
      return res.redirect("http://pdf.pineviewtorch.com/latest.pdf");
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
      return res.render('staff/staff');
    });
    app.get('/staff/articles', auth.requireStaff, staff.articles.index);
    app.get('/staff/articles/new', auth.requireStaff, staff.articles.new_get);
    app.post('/staff/articles/new', auth.requireStaff, staff.articles.new_post);
    app.get('/staff/articles/:slug', auth.requireStaff, articles.view);
    app.get('/staff/articles/:slug/stats.json', auth.requireStaff, staff.articles.stats);
    app.post('/staff/articles/:slug/comment', auth.requireStaff, staff.articles.comment);
    app.get('/staff/articles/:slug/edit', auth.requireStaff, staff.articles.edit_get);
    app.post('/staff/articles/:slug/edit', auth.requireStaff, staff.articles.edit_post);
    app.post('/staff/articles/:slug/delete', auth.requireStaff, staff.articles.remove);
    app.post('/staff/articles/:slug/photosDelete', auth.requireStaff, staff.articles.removePhotos);
    app.get('/staff/articles/:slug/photos/upload', auth.requireStaff, staff.photos.view);
    app.get("/staff/articles/:slug/photos/upload/signS3/:mime(\\w+\/\\w+)/:filename", auth.requireStaff, staff.photos.auth);
    app.get("/staff/articles/:slug/photos/upload/confirmed/:name", auth.requireStaff, staff.photos.addToDB);
    app.get('/staff/issues', auth.requireStaff, staff.issues.list);
    app.get('/staff/issues/new', auth.requireStaff, staff.issues.new_get);
    app.post('/staff/issues/new', auth.requireStaff, staff.issues.new_post);
    app.get('/staff/issues/:slug', auth.requireStaff, staff.issues.edit_get);
    app.post('/staff/issues/:slug', auth.requireStaff, staff.issues.edit_post);
    app.get('/staff/sections', auth.requireStaff, staff.sections.list);
    app.get('/staff/sections/new', auth.requireStaff, staff.sections.new_get);
    app.post('/staff/sections/new', auth.requireStaff, staff.sections.new_post);
    app.get('/staff/sections/:slug', auth.requireStaff, staff.sections.edit_get);
    app.post('/staff/sections/:slug', auth.requireStaff, staff.sections.edit_post);
    app.get('/staff/sections/:slug/delete', auth.requireStaff, staff.sections.remove);
    app.get('/staff/users', auth.requireStaff, staff.users.list);
    app.get('/staff/users/new', auth.requireStaff, staff.users.new_get);
    app.post('/staff/users/new', auth.requireStaff, staff.users.new_post);
    app.get('/staff/users/:slug', auth.requireStaff, staff.users.edit_get);
    app.post('/staff/users/:slug', auth.requireStaff, staff.users.edit_post);
    app.post('/staff/users/:slug/delete', auth.requireStaff, staff.users.remove);
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
