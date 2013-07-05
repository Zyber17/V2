db = require '../database'

exports.any = (req,res,next) ->
	checkLogin req, res, next, 0

exports.login.get = (req,res,next) ->
	checkLogin req, res, next, -1

exports.login.post = (req,res,next) ->
	if !checkLogin(req, res, next, -1)
		db.users.findOne # Stuff here later
	else
		res.redirect '/'

exports.logout = (req,res,next) ->
	req.session.destroy()
	res.redirect '/'

#more than no auth
exports.more = (req,res,next) ->
	checkLogin req, res, next, 1

exports.staff = (req,res,next) ->
	checkLogin req, res, next, 2


checkLogin = (req,res,next,level) ->
	#level: -1: retrun true or false, level 0: any, level 1: some, level 2: staff
	if req.session.user
		db.users.findOne {_id: req.session.user._id}, {password:0}, (err,resp) ->
			if err
				## throw a 500 err here later
			else if resp
				req.session.user = resp
				switch level
					when 2
						if resp.isStaff then next() else res.redirect('back', {error:'You must be a staff member to see this page.'})
					when -1
						return true
					else
						next()
			else
				res.redirect '/logout'
	else
		switch level
			when 0
				next()
			when -1
				return false
			else
				if level == 2
					msg = 'You must be a staff member and logged in to see this page.'
				else
					msg = 'You must be logged in to see this page'
				res.redirect('back', {error:msg})