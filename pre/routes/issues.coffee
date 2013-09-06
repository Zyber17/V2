db = require '../db'
moment = require 'moment'
# string = require 'string'

exports.list = (req,res,next) ->
	db.Issues.find(
		{},
		{publishDate:
			1
		title:
			1
		publication:
			1
		slug:
			1}
	).sort('-createdDate'
	).execFind(
		(err, resp) ->
			if !err
				issues = []
				for issue, i in resp
					issues[i] =
						title:
							issue.title
						date:
							moment(issue.publishDate).format("MMMM D, YYYY")
						exactDate:
							moment(issue.publishDate).toISOString().split('T')[0]
						slug:
							"/staff/issues/#{issue.slug}/"
						publication:
							issue.publication

				res.render 'issuesList', {issues: issues}
			else
				console.log "Error (issues): #{err}"
				res.end JSON.stringify err
	)

exports.new_get = (req,res,next) ->
	if req.session.message
		req.session.message.editing = false
		res.render 'newIssue', req.session.message
		req.session.message = null
	else
		res.render 'newIssue', {editing: false}

exports.new_post = (req,res,next) ->
	err = []
	if !req.body.date
		err.push "Date must be set."
	if !req.body.title or req.body.title.length < 3
		err.push "Name must be three characters or more."

	if err.length > 0
		req.session.message = req.body
		req.session.message.err = _err
		res.redirect '/staff/issues/new'
	else
		newIssue = new db.Issues
			title:
				req.body.title
			publication:
				req.body.publication
			publishDate:
				moment(req.body.date, "MM-DD-YYYY").toDate()
			createdDate:
				moment().toDate()

		newIssue.save (err,resp) ->
			if !err
				res.redirect '/staff/issues/'
			else
				console.log "Error (issues): #{err}"
				res.end JSON.stringify err

exports.edit_get = (req,res,next) ->
	if req.session.message
		req.session.message.editing = true
		res.render 'newIssue', req.session.message
		req.session.message = null
	else
		findIssue req.params.slug, (err,resp) ->
			if !err
				if resp
					send=
						title:
							resp.title
						publication:
							resp.publication
						date:
							moment(resp.publishDate).format("MM-DD-YYYY")
						editing:
							true

					res.render 'newIssue', send
				else
					res.render 'errors/404', {err: "Issue not found"}
			else
				console.log "Error (issues): #{err}"
				res.end JSON.stringify err

exports.edit_post = (req,res,next) ->
	err = []
	if !req.body.date
		err.push "Date must be set."
	if !req.body.title or req.body.title.length < 3
		err.push "Name must be three characters or more."

	if err.length > 0
		req.session.message = req.body
		req.session.message.err = _err
		res.redirect "/staff/issues/#{req.params.slug}"
	else
		findIssue req.params.slug, (err,resp) ->
			if !err
				if resp
					resp.title = req.body.title
					resp.date = moment(req.body.date, "MM-DD-YYYY").toDate()
					resp.publication = req.body.publication

					resp.save (err, resp) ->
						if err
							console.log "Error (issues): #{err}"
							res.end JSON.stringify err
						else
							res.redirect "/staff/issues/"
				else
					res.render 'errors/404', {err: "Article not found"}
			else
				console.log "Error (issues): #{err}"
				res.end JSON.stringify err


findIssue = (slug, callback) ->
	db.Issues.findOne(
		slug:
			slug
	).select(
		publishDate:
			1
		title:
			1
		publication:
			1
		slug:
			1
	).exec((err, resp) ->
		callback(err,resp)
	)