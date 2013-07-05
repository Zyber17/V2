express  =  require 'express'

article  =  require './routes/article'
auth     =  require './routes/auth'
index    =  require './routes/index'
issues   =  require './routes/issues'
search   =  require './routes/search'
section  =  require './routes/section'
user     =  require './routes/user'

staff = []
staff.articles     =  require './routes/staff/articles'
staff.index        =  require './routes/staff/index'
staff.issues       =  require './routes/staff/issues'
staff.permissions  =  require './routes/staff/permissions'
staff.photos       =  require './routes/staff/photos'
staff.rotator      =  require './routes/staff/rotator'
staff.sections     =  require './routes/staff/sections'
staff.users        =  require './routes/staff/users'

app = express()

app.configure ->
	# sessions
	app.use express.cookieParser('***REMOVED***')
	app.use express.static(path.join(__dirname, 'public'))
	app.use express.favicon('./public/images/favicon.ico')
	app.use express.bodyParser
	app.use (req, res, next) ->
		res.status(404).render 'errors/404'

	app.set 'view engine', 'jade'

	app.disable 'x-powered-by'

	true # CoffeeScript automatically returns the last line of every function. So, we're returning true when eveything works (last line excuted).

app.get '/', index.view

app.get '/article/:slug', auth.any, article.view # Middleware for auth?

app.get '/issues', issues.list

app.get '/issues/:id', issues.view

app.get '/login', auth.login

app.get '/logout', auth.logout

app.get '/rss', rss.view

app.get '/search/:query', search.search

app.get '/section/:name', section.view

app.get '/settings', auth.more, settings.edit.get

app.post '/settings', auth.more, settings.edit.post

app.get '/user/:name', user.view


###
Staff Stuff
###

app.get '/staff', auth.staff, staff.index.view


app.get '/staff/articles', auth.staff, staff.articles.list

app.get '/staff/articles/:id', auth.staff, staff.articles.view

app.get '/staff/articles/:id/edit', auth.staff, staff.articles.edit.get

app.post '/staff/articles/:id/edit', auth.staff, staff.articles.edit.post
# Photos
app.get '/staff/articles/:id/photos', auth.staff, staff.articles.photos.list

app.get '/staff/articles/:id/photos/:pid', auth.staff, staff.articles.photos.view

app.get '/staff/articles/:id/photos/:pid/edit', auth.staff, staff.articles.photos.edit.get

app.post '/staff/articles/:id/photos/:pid/edit', auth.staff, staff.articles.photos.edit.post

app.post '/staff/articles/:id/photos/upload', auth.staff, staff.articles.photos.upload.get

app.post '/staff/articles/:id/photos/upload', auth.staff, staff.articles.photos.upload.post
#End Photos
app.get '/staff/articles/new', auth.staff, staff.articles.new.get

app.post '/staff/articles/new', auth.staff, staff.articles.new.post

app.post '/staff/articles/:id/delete', auth.staff, staff.articles.delete


app.get '/staff/issues', auth.staff, staff.issues.list

app.get '/staff/issues/:id', auth.staff, staff.issues.view

app.get '/staff/issues/:id/edit', auth.staff, staff.issues.edit.get

app.post '/staff/issues/:id/edit', auth.staff, staff.issues.edit.post

app.get '/staff/issues/new', auth.staff, staff.issues.new.get

app.post '/staff/issues/new', auth.staff, staff.issues.new.post

app.post '/staff/issues/:id/delete', auth.staff, staff.issues.delete


app.get '/staff/permissions', auth.staff, staff.permissions.list

app.get '/staff/permissions/:id', auth.staff, staff.permissions.view

app.get '/staff/permissions/:id/edit', auth.staff, staff.permissions.edit.get

app.post '/staff/permissions/:id/edit', auth.staff, staff.permissions.edit.post

app.get '/staff/permissions/new', auth.staff, staff.permissions.new.get

app.post '/staff/permissions/new', auth.staff, staff.permissions.new.post

app.post '/staff/permissions/:id/delete', auth.staff, staff.permissions.delete


app.get '/staff/planners/:name', auth.staff, staff.planners.view

app.get '/staff/planners/view/:section', auth.staff, staff.planners.list

app.get '/staff/planners/:name/edit', auth.staff, staff.planners.edit.get

app.post '/staff/planners/:name/edit', auth.staff, staff.planners.edit.post

app.get '/staff/planners/new', auth.staff, staff.planners.new.get

app.post '/staff/planners/new', auth.staff, staff.planners.new.post

app.post '/staff/planners/:name/delete', auth.staff, staff.permissions.delete


app.get '/staff/rotator', auth.staff, staff.rotator.list

app.get '/staff/rotator/:id', auth.staff, staff.rotator.view

app.get '/staff/rotator/:id/edit', auth.staff, staff.rotator.edit.get

app.post '/staff/rotator/:id/edit', auth.staff, staff.rotator.edit.post

app.get '/staff/rotator/new', auth.staff, staff.rotator.new.get

app.post '/staff/rotator/new', auth.staff, staff.rotator.new.post

app.post '/staff/rotator/:id/delete', auth.staff, staff.rotator.delete


app.get '/staff/users', auth.staff, staff.users.list

app.get '/staff/users/:id', auth.staff, staff.users.view

app.get '/staff/users/:id/edit', auth.staff, staff.users.edit.get

app.post '/staff/users/:id/edit', auth.staff, staff.users.edit.post

app.get '/staff/users/new', auth.staff, staff.users.new.get

app.post '/staff/users/new', auth.staff, staff.users.new.post

app.post '/staff/users/:id/delete', auth.staff, staff.users.delete

###
End Staff Suff
###


# To set the enviroment: http://stackoverflow.com/questions/11104028/process-env-node-env-is-undefined

app.configure 'development', ->
  	app.listen 8000

app.configure 'production', ->
  	app.listen 80