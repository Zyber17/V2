db = require '../db'

exports.optionalLogin = (req, res, next) ->
	if req.session.user
		db.Users.findOne {_id: req.session.user._id}, {password:0}, (err, resp) ->
				if !errn
					if resp
						req.session.isUser = true
						req.session.user = resp
						next()

					else
						res.redirect '/logout'

				else
					console.log "Error (auth): #{err}"
					res.end JSON.stringify err
	else
		req.session.isUser = false
		next()


exports.requireStaff = (req,res,next) ->
	if req.session.user
		if req.session.user.isStaff == true
			req.session.user = resp
			next()
		else
			res.redirect '/'
		
	else
		res.redirect '/login'


exports.login_get = (req,res,next) ->
	if req.session.message
		res.render 'login', req.session.message
		req.session.message = null
	else
		res.render 'login'

exports.login_post = (req,res,next) ->
	err = []
	if !req.body.username
		err.push 'Username reqired.'

	if !req.body.password or req.body.password.length < 10
		err.push 'Password must be ten characters or longer.'

	if err.length > 0
		req.session.message = req.body
		res.redirect '/login'
	else
		db.User.findOne {username: req.body.username.toLowerCase()}, (err, resp) ->
				if !err
					if resp
						resp.comparePassword req.body.password, (err, isMatch) ->
	           				if !err
	           					if isMatch
	            					next()
	            				else
	            					req.session.message = req.body
	            					res.redirect '/'
	            			else
	            				console.log "Error (auth): #{err}"
								res.end JSON.stringify err
					else
						res.redirect '/logout'
				else
					console.log "Error (auth): #{err}"
					res.end JSON.stringify err

exports.logout = (req,res,next) ->
        req.session.destroy()
        res.redirect '/'