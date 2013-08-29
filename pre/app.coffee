cluster = require 'cluster'
if cluster.isMaster
	cpus = require('os').cpus().length

	for cpu in [0...cpus]
		cluster.fork()

	cluster.on 'exit', (worker) ->
		# Replace the dead worker, we're not sentimental
	    console.log "Worker #{worker.id} died :("
	    cluster.fork()

else    
	express  =  require 'express'
	http     =  require 'http'
	path     =  require 'path'

	articles  =  require './routes/articles'
	# auth     =  require './routes/auth'
	# index    =  require './routes/index'
	issues   =  require './routes/issues'
	# search   =  require './routes/search'
	sections  =  require './routes/sections'
	users    =  require './routes/users'
	photos    =  require './routes/photos'

	# staff = []
	# staff.articles     =  require './routes/staff/articles'
	# staff.index        =  require './routes/staff/index'
	# staff.issues       =  require './routes/staff/issues'
	# staff.permissions  =  require './routes/staff/permissions'
	# staff.photos       =  require './routes/staff/photos'
	# staff.rotator      =  require './routes/staff/rotator'
	# staff.sections     =  require './routes/staff/sections'
	# staff.users        =  require './routes/staff/users'

	app = express()


	app.configure ->
		app.use express.cookieParser('***REMOVED***')
		app.use express.static(path.join(__dirname, 'public'))
		#app.use express.favicon('./public/images/favicon.ico')
		app.use express.session({ cookie: { maxAge: 15552000000 }})
		app.use express.bodyParser()
		app.set 'views', __dirname + '/views'
		app.set 'view engine', 'jade'

		app.disable 'x-powered-by'

		app.set 'port', process.env.PORT || 8000

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

	app.get '/articles/:slug', auth.optionalLogin, articles.view # Middleware for auth? Update: No. Just check for session in article.view. WAIT. I MEAN YES. Just make sure the user in reference exists. Add later


	###
	/Update this stuff
	###

	# app.get '/issues', issues.list

	# app.get '/issues/:id', issues.edit_get

	app.get '/login', auth.login_get

	app.post '/login', auth.login_post

	app.get '/logout', auth.logout

	# app.get '/rss', rss.view

	# app.get '/search/:query', search.search

	# app.get '/section/:name', section.view

	# app.get '/settings', auth.more, settings.edit.get

	# app.post '/settings', auth.more, settings.edit.post

	# app.get '/user/:name', user.view


	###
	Staff Stuff
	###

	# Articles

	# app.get '/staff', auth.requireStaff, staff.index.view


	app.get '/staff/articles/new', auth.requireStaff, articles.new_get

	app.post '/staff/articles/new', auth.requireStaff, articles.new_post

	app.get '/staff/articles/:slug', auth.requireStaff, articles.view # Middleware for auth? Update: No. Just check for session in article.view. WAIT. I MEAN YES. Just make sure the user in reference exists. Add later

	app.post '/staff/articles/:slug/comment', auth.requireStaff, articles.comment

	app.get '/staff/articles/:slug/edit', auth.requireStaff, articles.edit_get

	app.post '/staff/articles/:slug/edit', auth.requireStaff, articles.edit_post

	app.post '/staff/articles/:slug/delete', auth.requireStaff, articles.remove

	# End Articles
	# Photos

	app.get '/staff/articles/:slug/photos/upload', auth.requireStaff, photos.view

	app.get "/staff/articles/:slug/photos/upload/signS3/:mime(\\w+\/\\w+)", auth.requireStaff, photos.auth

	app.get "/staff/articles/:slug/photos/upload/confirmed/:id(\\d+)", auth.requireStaff, photos.addToDB

	# End Photos
	# Issues

	app.get '/staff/issues', auth.requireStaff, issues.list

	app.get '/staff/issues/new', auth.requireStaff, issues.new_get

	app.post '/staff/issues/new', auth.requireStaff, issues.new_post

	app.get '/staff/issues/:slug', auth.requireStaff, issues.edit_get

	app.post '/staff/issues/:slug', auth.requireStaff, issues.edit_post

	# End Issues
	# Sections

	app.get '/staff/sections', auth.requireStaff, sections.list

	app.get '/staff/sections/new', auth.requireStaff, sections.new_get

	app.post '/staff/sections/new', auth.requireStaff, sections.new_post

	app.get '/staff/sections/:slug', auth.requireStaff, sections.edit_get

	app.post '/staff/sections/:slug', auth.requireStaff, sections.edit_post

	# End Sections
	# Users

	app.get '/staff/users', auth.requireStaff, users.list

	app.get '/staff/users/new', auth.requireStaff, users.new_get

	app.post '/staff/users/new', auth.requireStaff, users.new_post

	app.get '/staff/users/:slug', auth.requireStaff, users.edit_get

	app.post '/staff/users/:slug', auth.requireStaff, users.edit_post

	app.post '/staff/users/:slug/delete', auth.requireStaff, users.remove

	# End Users


	# app.get '/staff/planners/:name', auth.staff, staff.planners.view

	# app.get '/staff/planners/view/:section', auth.staff, staff.planners.list

	# app.get '/staff/planners/:name/edit', auth.staff, staff.planners.edit.get

	# app.post '/staff/planners/:name/edit', auth.staff, staff.planners.edit.post

	# app.get '/staff/planners/new', auth.staff, staff.planners.new.get

	# app.post '/staff/planners/new', auth.staff, staff.planners.new.post

	# app.post '/staff/planners/:name/delete', auth.staff, staff.permissions.delete



	# app.get '/staff/users', auth.staff, staff.users.list

	# app.get '/staff/users/:slug', auth.staff, staff.users.edit_get

	# app.post '/staff/users/:slug', auth.staff, staff.users.edit_post

	# app.get '/staff/users/new', auth.staff, staff.users.new_get

	# app.post '/staff/users/new', auth.staff, staff.users.new_post

	# app.post '/staff/users/:id/delete', auth.staff, staff.users.remove

	###
	End Staff Suff
	###

	app.listen app.get('port'), ->
		console.log "Express server listening on port " + app.get('port')
		console.log "Worker #{cluster.worker.id} running!"