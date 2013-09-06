db = require '../db'

exports.optionalLogin = (req, res, next) ->
	if req.session.user
		db.Users.findOne {_id: req.session.user._id}, {password:0}, (err, resp) ->
			if !err
				if resp
					req.session.isUser = true
					if resp.isStaff then req.session.isStaff = true else req.session.isStaff = false
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
		db.Users.findOne {_id: req.session.user._id}, {password:0}, (err, resp) ->
			if !err
				if resp
					req.session.isUser = true
					if resp.isStaff then req.session.isStaff = true else req.session.isStaff = false
					req.session.user = resp
					next()
				else
					res.redirect '/logout'

			else
				console.log "Error (auth): #{err}"
				res.end JSON.stringify err
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
		req.session.message._err = err
		res.redirect '/login'
	else
		db.Users.findOne(
			{username: req.body.username}
			(err, resp) ->
				if !err
					if resp
						resp.comparePassword req.body.password, (err, isMatch) ->
								if !err
									if isMatch
										req.session.user = resp
										req.session.isUser = true
										
										if resp.isStaff
											req.session.isStaff = true
											res.redirect '/staff/'
										else
											req.session.isStaff = false
											res.redirect '/'
										
									else
										req.session.message = req.body
										req.session.message._err = ["Invalid password"]
										res.redirect '/login'
								else
									console.log "Error (auth): #{err}"
									res.end JSON.stringify err
					else
						req.session.message = req.body
						req.session.message._err = ["Invalid username"]
						res.redirect '/login'
				else
					console.log "Error (auth): #{err}"
					res.end JSON.stringify err
		)

exports.logout = (req,res,next) ->
		req.session.destroy()
		res.redirect '/'