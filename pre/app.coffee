express  =  require 'express'

article  =  require './routes/article'
auth     =  require './routes/auth'
index    =  require './routes/index'
issues   =  require './routes/issues'
search   =  require './routes/search'
section  =  require './routes/section'
user     =  require './routes/user'

staff = []
staff.articles = require './routes/staff/articles'
staff.index = require './routes/staff/index'
staff.issues = require './routes/staff/issues'
staff.permissions = require './routes/staff/permissions'
staff.rotator = require './routes/staff/rotator'
staff.sections = require './routes/staff/sections'
staff.users = require './routes/staff/users'

app = express()

app.configre ->
	app.use express.cookieParser('g8GJ3xBtIBv34LbFev09eCAEvOC3wt')
	true # CoffeeScript automatically returns the last line of any function. So, we're returning true when eveything works (last line excuted).

app.get '/', index.view

app.get '/article/:id', article.view # Middleware for auth?

app.get '/issues', issues.list

app.get '/issues/:id', issues.view

app.get '/search/:query', search.search

app.get '/section/:id', section.view

app.get '/user/:name', user.view


###
Staff Stuff
###

app.get '/staff', auth.staff, staff.index.view


app.get '/staff/articles', auth.staff, staff.articles.list

app.get '/staff/articles/:id', auth.staff, staff.articles.view

app.get '/staff/articles/:id/edit', auth.staff, staff.articles.edit

app.post '/staff/articles/:id/edit', auth.staff, staff.articles.edit

app.get '/staff/articles/new', auth.staff, staff.articles.new

app.post '/staff/articles/new', auth.staff, staff.articles.new


app.get '/staff/issues', auth.staff, staff.issues.list

app.get '/staff/issues/:id', auth.staff, staff.issues.view


app.get '/staff/permissions', auth.staff, staff.permissions.list

app.get '/staff/permissions/:id', auth.staff, staff.permissions.view

app.get '/staff/permissions/:id/edit', auth.staff, staff.permissions.edit

app.post '/staff/permissions/:id/edit', auth.staff, staff.permissions.edit

app.get '/staff/permissions/new', auth.staff, staff.permissions.new

app.post '/staff/permissions/new', auth.staff, staff.permissions.new


app.get '/staff/planners/:id', auth.staff, staff.planners.view

app.get '/staff/planners/view/:section', auth.staff, staff.planners.list

app.get '/staff/planners/new', auth.staff, staff.planners.new

app.post '/staff/planners/new', auth.staff, staff.planners.new

app.get '/staff/planners/:id/edit', auth.staff, staff.planners.edit

app.post '/staff/planners/:id/edit', auth.staff, staff.planners.edit


app.get '/staff/rotator', auth.staff, staff.rotator.list

app.get '/staff/rotator/:id/edit', auth.staff, staff.rotator.edit

app.post '/staff/rotator/:id/edit', auth.staff, staff.rotator.edit

app.get '/staff/rotator/new', auth.staff, staff.rotator.new

app.post '/staff/rotator/new', auth.staff, staff.rotator.new


app.get '/staff/users', auth.staff, staff.users.list

app.get '/staff/users/:id', auth.staff, staff.users.view

app.get '/staff/users/:id/edit', auth.staff, staff.users.edit

app.post '/staff/users/:id/edit', auth.staff, staff.users.edit

app.get '/staff/users/new', auth.staff, staff.rotator.new

app.post '/staff/users/new', auth.staff, staff.rotator.new

###
End Staff Suff
###


# To set the enviroment: http://stackoverflow.com/questions/11104028/process-env-node-env-is-undefined

app.configure 'development', ->
  	app.listen 8000

app.configure 'production', ->
  	app.listen 80