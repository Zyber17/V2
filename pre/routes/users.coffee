db = require '../db'
moment = require 'moment'
marked = require 'marked'
string = require 'string'

marked.setOptions
	gfm:
		true
	breaks:
		true
	tables:
	 	false
	sanitize:
		true


exports.list = (req,res,next) ->
	db.Users.find(
		{},
		{password:
			0
		permissions:
			0
		bio:
			0
		email:
			0
		}
	).sort('name'
	).execFind(
		(err, resp) ->
			#slug defined in userList
			res.render 'userList', {users: resp}
	)


exports.new_get = (req,res,next) ->
	if req.session.message
		res.render 'newUser', req.session.message
		req.session.message = null
	else
		res.render 'newUser'

exports.new_post = (req,res,next) ->
	err = []
	if !req.body.name or req.body.name.length <= 3
		err.push 'Name must be longer than three characters.'

	if !req.body.username or req.body.username.length < 0
		err.push 'Username must be longer than zero characters.'
	
	if !req.body.password or req.body.password.length < 10
		err.push 'Password must be ten characters or longer.'
	
	if req.body.bio and req.body.bio.length < 20
		err.push 'A bio must either not exist (be completely empty) or be longer than twenty characters.'

	#regex \S+@\S+\.\S+ = One+ anything not whitespace, @, one+ anything not whitespace, ., two+ anything not whitespace. Minimum of six characters (a@b.me)
	if req.body.email and !/\S+@\S+\.\S\S+/.test(req.body.email)
		err.push 'Emails must be six characters or longer, contain both peroid and an at sign, and contain no whitespace. Leave the feild blank to have the email be automagically guessed.'
	
	if err.length > 0
		req.session.message = req.body
		req.session.message.dispBio = req.body.bio
		req.body.knowsHTML = string(req.body.knowsHTML).toBool()
		req.body.canPublishStories = string(req.body.canPublishStories).toBool()
		req.body.canDeletePhotos = string(req.body.canDeletePhotos).toBool()
		req.body.canManageIssues = string(req.body.canManageIssues).toBool()
		req.body.canManageUsers = string(req.body.canManageUsers).toBool()
		req.body.canManageSections = string(req.body.canManageSections).toBool()
		req.body.canEditPlannerFormats = string(req.body.canEditPlannerFormats).toBool()
		req.body.canAcceptPlanners = string(req.body.canAcceptPlanners).toBool()
		req.body.canEditOthersComments = string(req.body.canEditOthersComments).toBool()
		req.body.canComment = string(req.body.canComment).toBool()
		req.body.canChat = string(req.body.canChat).toBool()
		req.body.isWebmaster = string(req.body.isWebmaster).toBool()
		req.body.isRetired = string(req.body.isRetired).toBool()
		req.body.isDisabled = string(req.body.isDisabled).toBool()
		req.session._err = err
		res.redirect '/staff/users/new'
	else
		newUser = new db.Users
			username:
				req.body.username
			name:
				req.body.name
			bio:
				rendered:
					if req.body.bio then marked(req.body.bio) else null
				notRendered:
					req.body.bio || null
			email:
				req.body.email || "#{req.body.name.toLowerCase().replace(' ','.')}@pineviewtorch.com"
			isStaff:
					req.body.isStaff
			password:
				req.body.password
			permissions:
				knowsHTML:
					req.body.knowsHTML || false
				canPublishStories:
					req.body.canPublishStories || false
				canDeletePhotos:
					req.body.canDeletePhotos || false
				canManageIssues:
					req.body.canManageIssues || false
				canManageUsers:
					req.body.canManageUsers || false
				canManageSections:
					req.body.canManageSections || false
				canEditPlannerFormats:
					req.body.canEditPlannerFormats || false
				canAcceptPlanners:
					req.body.canAcceptPlanners || false
				canEditOthersComments:
					req.body.canEditOthersComments || false
				canComment:
					req.body.canComment || false
				canChat:
					req.body.canChat || false
				accountStatus:
					isWebmaster:
						req.body.isWebmaster || false
					isRetired:
						req.body.isRetired || false
					isDisabled:
						req.body.isDisabled || false
		
		newUser.save (err,resp) ->
			if err == null
				res.redirect "/staff/users/#{resp.slug}/"
			else
	        	console.log "Error (users): #{err}"
				res.end JSON.stringify err


exports.edit_get = (req,res,next) ->
	if req.session.message
		res.render 'newUser', req.session.message
		req.session.message = null
	else
		findUser req.params.slug,(err, resp) ->
			if !err
				if resp
					resp.dispBio = resp.bio.notRendered
					collect resp._doc, resp._doc.permissions, resp._doc.permissions.accountStatus, (ret) ->
						delete ret.permissions
						delete ret.accountStatus
						delete ret.bio
						ret.dispBio = resp.bio.notRendered
						res.render 'newUser', ret
				else
					res.render 'errors/404', {err: "User not found"}
			else
				console.log "Error (users): #{err}"
				res.end JSON.stringify err


exports.edit_post = (req,res,next) ->
	err = []
	if !req.body.name or req.body.name.length <= 3
		err.push 'Name must be longer than three characters.'

	if !req.body.username or req.body.username.length < 0
		err.push 'Username must be longer than zero characters.'
	
	if req.body.password and req.body.password.length < 10
		err.push 'Password must be ten characters or longer.'
	
	if req.body.bio and req.body.bio.length < 20
		err.push 'A bio must either not exist (be completely empty) or be longer than twenty characters.'

	#regex \S+@\S+\.\S+ = One+ anything not whitespace, @, one+ anything not whitespace, ., two+ anything not whitespace. Minimum of six characters (a@b.me)
	if req.body.email and !/\S+@\S+\.\S\S+/.test(req.body.email)
		err.push 'Emails must be six characters or longer, contain both peroid and an at sign, and contain no whitespace. Leave the feild blank to have the email be automagically guessed.'
	
	if err.length > 0
		req.session.message = req.body
		req.session.message._err = err
		req.body.knowsHTML = string(req.body.knowsHTML).toBool()
		req.body.canPublishStories = string(req.body.canPublishStories).toBool()
		req.body.canDeletePhotos = string(req.body.canDeletePhotos).toBool()
		req.body.canManageIssues = string(req.body.canManageIssues).toBool()
		req.body.canManageUsers = string(req.body.canManageUsers).toBool()
		req.body.canManageSections = string(req.body.canManageSections).toBool()
		req.body.canEditPlannerFormats = string(req.body.canEditPlannerFormats).toBool()
		req.body.canAcceptPlanners = string(req.body.canAcceptPlanners).toBool()
		req.body.canEditOthersComments = string(req.body.canEditOthersComments).toBool()
		req.body.canComment = string(req.body.canComment).toBool()
		req.body.canChat = string(req.body.canChat).toBool()
		req.body.isWebmaster = string(req.body.isWebmaster).toBool()
		req.body.isRetired = string(req.body.isRetired).toBool()
		req.body.isDisabled = string(req.body.isDisabled).toBool()
		res.redirect "/staff/users/#{req.params.slug}/"
	else
		findUser req.params.slug, (err, resp) ->
			if !err
				if resp
					resp.username = req.body.username
					resp.name = req.body.name
					resp.bio =
						rendered:
							if req.body.bio then marked(req.body.bio) else null
						notRendered:
							req.body.bio || null
					resp.email = req.body.email || "#{req.body.name.toLowerCase().replace(' ','.')}@pineviewtorch.com"
					resp.isStaff = req.body.isStaff
					resp.permissions=
						knowsHTML:
							string(req.body.knowsHTML).toBool()
						canPublishStories:
							req.body.canPublishStories || false
						canDeletePhotos:
							req.body.canDeletePhotos || false
						canManageIssues:
							req.body.canManageIssues || false
						canManageUsers:
							req.body.canManageUsers || false
						canManageSections:
							req.body.canManageSections || false
						canEditPlannerFormats:
							req.body.canEditPlannerFormats || false
						canAcceptPlanners:
							req.body.canAcceptPlanners || false
						canEditOthersComments:
							req.body.canEditOthersComments || false
						canComment:
							req.body.canComment || false
						canChat:
							req.body.canChat || false
						accountStatus:
							isWebmaster:
								req.body.isWebmaster || false
							isRetired:
								req.body.isRetired || false
							isDisabled:
								req.body.isDisabled || false
					if req.body.password
						resp.password = req.body.password
					resp.save (err, resp) ->
						if err
							console.log "Error (users): #{err}"
							res.end JSON.stringify err
						else
							res.redirect "/staff/users/#{resp.slug}/"


				else
					res.render 'errors/404', {err: "User not found"}
			else
				console.log "Error (users): #{err}"
				res.end JSON.stringify err


exports.remove = (req,res,next) ->
	if req.body.delete == "true"
		db.Users.findOneAndRemove {
			slug:
				req.params.slug
		}, (err, resp) ->
			if !err
				res.redirect '/'
			else
				console.log "Error (users): #{err}"
				res.end JSON.stringify err
	else
		res.redirect "/staff/users/#{resp.slug}/" 
# Fix these later
exports.change_get = (req,res,next) ->
	if req.session.message
		res.render 'newUser', req.session.message
		req.session.message = null
	else
		db.Users.findById req.session.user._id, {
				username:
					1
				name:
					1
			}, (err, resp) ->
			if !err
				if resp
					res.render 'userSettings', resp
				else
					res.render '/logout'
			else
				console.log "Error (users): #{err}"
				res.end JSON.stringify err

exports.change_post = (req,res,next) ->
	true
#End fix this later
findUser = (slug, callback) ->
	db.Users.findOne {slug: slug}, {password:0}, (err,resp) ->
		callback(err,resp)
collect = (args...,callback) ->
	ret = {}
	len = args.length
	for i in [0...len]
		for own k,v of args[i]
			ret[k] = v
	callback(ret)