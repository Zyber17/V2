cluster = require 'cluster'
if cluster.isMaster
	console.log "V2 running in a #{if process.env.NODE_ENV then '`'+process.env.NODE_ENV+'`' else 'production'} environment."

	if process.env.NODE_ENV == 'setup'
		console.log 'Starting setup process.'

		express  =  require 'express'
		setup    =  require './routes/setup'
		app      =  express()

		app.configure 'setup', ->
			setup (resp) ->
				console.log resp
				process.kill process.pid, "SIGTERM"

	else
		cpus = require('os').cpus().length

		for cpu in [0...cpus]
			cluster.fork()

		cluster.on 'exit', (worker) ->
			# Replace the dead worker, we're not sentimental
			console.log "Worker #{worker.id} died :("
			cluster.fork()

else if process.env.NODE_ENV != 'setup'
	express     =  require 'express'
	http        =  require 'http'
	moment      =  require 'moment'
	path        =  require 'path'
	RedisStore  =  require('connect-redis')(express)

	auth       =  require './routes/auth'

	articles   =  require './routes/articles'
	# index    =  require './routes/index'
	# issues     =  require './routes/issues'
	search		=  require './routes/search'
	rss        =  require './routes/rss'
	sections   =  require './routes/sections'
	# users      =  require './routes/users'
	# photos     =  require './routes/photos'

	staff = []
	staff.articles     =  require './routes/staff/articles'
	# staff.index        =  require './routes/staff/index'
	staff.issues       =  require './routes/staff/issues'
	# staff.permissions  =  require './routes/staff/permissions'
	staff.photos       =  require './routes/staff/photos'
	# staff.rotator      =  require './routes/staff/rotator'
	staff.sections     =  require './routes/staff/sections'
	staff.users        =  require './routes/staff/users'

	app = express()


	app.configure ->
		app.use express.cookieParser('**REMOVED**')
		app.use express.static(path.join(__dirname, 'public'))
		app.use express.favicon(path.join(__dirname, 'public/images/favicon.ico'))
		app.use express.bodyParser()
		app.use(
			express.session
				store:
					new RedisStore
				secret:
					'**REMOVED**'
		)

		moment.lang('en'
		    monthsShort:[
		        "Jan."
		        "Feb."
		        "March"
		        "April"
		        "May"
		        "June"
		        "July"
		        "Aug."
		        "Sept."
		        "Oct."
		        "Nov."
		        "Dec."
		    ]
		)

		app.set 'views', __dirname + '/views'
		app.set 'view engine', 'jade'

		app.disable 'x-powered-by'

		app.set 'port', process.env.PORT || 8000

		app.use app.router
		app.use (req,res,next) -> res.render 'errors/404', 404

		app.use express.csrf()

		true # CoffeeScript automatically returns the last line of every function. So, we're returning true when eveything works (last line excuted).

	# To set the enviroment: http://stackoverflow.com/questions/11104028/process-env-node-env-is-undefined

	# app.configure 'development', ->
	#   	app.listen 8000

	# app.configure 'production', ->
	#   	app.listen 80
	#   	app.enable 'view cache'


	###
	Update this stuff
	###
	app.get '/', articles.index

	app.get '/articles.json', articles.json

	app.get '/articles/:slug', auth.optionalLogin, articles.view # Middleware for auth? Update: No. Just check for session in article.view. WAIT. I MEAN YES. Just make sure the user in reference exists. Add later

	app.get '/search', search.searchDirector


	###
	/Update this stuff
	###

	# app.get '/issues', issues.list

	app.get '/issues/current', (req,res,next) ->
		res.redirect "http://pdf.pineviewtorch.com/latest.pdf" ##{if moment() < moment("2014-11-21") then 'october_2014' else 'november_2014'}

	# app.get '/issues/:id', issues.edit_get

	app.get '/login', auth.login_get

	app.post '/login', auth.login_post

	app.get '/logout', auth.logout

	app.get '/rss', rss

	# app.get '/search/:query', search.search

	app.get '/sections/:slug', sections.view

	# app.get '/settings', auth.more, settings.edit.get

	# app.post '/settings', auth.more, settings.edit.post

	# app.get '/user/:name', user.view


	###
	Staff Stuff
	###

	# Articles

	app.get '/staff', auth.requireStaff, (req,res,next) -> res.render 'staff/staff'

	app.get '/staff/articles', auth.requireStaff, staff.articles.index

	app.get '/staff/articles/new', auth.requireStaff, staff.articles.new_get

	app.post '/staff/articles/new', auth.requireStaff, staff.articles.new_post

	app.get '/staff/articles/:slug', auth.requireStaff, articles.view # Middleware for auth? Update: No. Just check for session in article.view. WAIT. I MEAN YES. Just make sure the user in reference exists. Add later

	app.get '/staff/articles/:slug/stats.json', auth.requireStaff, staff.articles.stats

	app.post '/staff/articles/:slug/comment', auth.requireStaff, staff.articles.comment

	app.get '/staff/articles/:slug/edit', auth.requireStaff, staff.articles.edit_get

	app.post '/staff/articles/:slug/edit', auth.requireStaff, staff.articles.edit_post

	app.post '/staff/articles/:slug/delete', auth.requireStaff, staff.articles.remove

	app.post '/staff/articles/:slug/photosDelete', auth.requireStaff, staff.articles.removePhotos

	# End Articles
	# Photos

	app.get '/staff/articles/:slug/photos/upload', auth.requireStaff, staff.photos.view

	app.get "/staff/articles/:slug/photos/upload/signS3/:mime(\\w+\/\\w+)/:filename", auth.requireStaff, staff.photos.auth

	app.get "/staff/articles/:slug/photos/upload/confirmed/:name", auth.requireStaff, staff.photos.addToDB

	# End Photos
	# Issues

	app.get '/staff/issues', auth.requireStaff, staff.issues.list

	app.get '/staff/issues/new', auth.requireStaff, staff.issues.new_get

	app.post '/staff/issues/new', auth.requireStaff, staff.issues.new_post

	app.get '/staff/issues/:slug', auth.requireStaff, staff.issues.edit_get

	app.post '/staff/issues/:slug', auth.requireStaff, staff.issues.edit_post

	# End Issues
	# Sections

	app.get '/staff/sections', auth.requireStaff, staff.sections.list

	app.get '/staff/sections/new', auth.requireStaff, staff.sections.new_get

	app.post '/staff/sections/new', auth.requireStaff, staff.sections.new_post

	app.get '/staff/sections/:slug', auth.requireStaff, staff.sections.edit_get

	app.post '/staff/sections/:slug', auth.requireStaff, staff.sections.edit_post

	app.get '/staff/sections/:slug/delete', auth.requireStaff, staff.sections.remove

	# End Sections
	# Users

	app.get '/staff/users', auth.requireStaff, staff.users.list

	app.get '/staff/users/new', auth.requireStaff, staff.users.new_get

	app.post '/staff/users/new', auth.requireStaff, staff.users.new_post

	app.get '/staff/users/:slug', auth.requireStaff, staff.users.edit_get

	app.post '/staff/users/:slug', auth.requireStaff, staff.users.edit_post

	app.post '/staff/users/:slug/delete', auth.requireStaff, staff.users.remove

	# End Users

	###
	End Staff Suff
	###

	app.listen app.get('port'), ->
		console.log "Express server listening on port " + app.get('port')
		console.log "Worker #{cluster.worker.id} running!"
else
	console.log "Uhh. This should never happen. See app.js."
