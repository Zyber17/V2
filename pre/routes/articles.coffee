db = require '../db'
moment = require 'moment'
marked = require 'marked'
string = require 'string'
R = require 'rss'

marked.setOptions
	gfm:
		true
	breaks:
		true
	tables:
	 	false
	sanitize:
		true


exports.index = (req,res,next) ->
	db.Articles.find(
		{publishDate:
			$lte:
				moment().toDate()
		status:
			4},
		{publishDate:
			1
		body:
			1
		title:
			1
		author:
			1
		slug:
			1}
	).sort('-publishDate'
	).limit(3
	).execFind(
		(err, recent) ->
			if !err
				if recent.length
					recentAr = []
					for article, i in recent
						recentAr[i] =
							body:
								string(article.body[0].body).truncate(250).s
							author:
								article.author
							title:
								article.title
							date:
								moment(article.publishDate).format("MMMM D, YYYY")
							exactDate:
								moment(article.publishDate).toISOString().split('T')[0]
							slug:
								"/articles/#{article.slug}/"

						db.Articles.find(
							{publishDate:
								$lte:
									moment().toDate()
							status:
								4
							isRotator:
								true},
							{publishDate:
								1
							body:
								1
							title:
								1
							author:
								1
							slug:
								1}
						).sort('-publishDate'
						).limit(4
						).execFind(
							(err, rotator) ->
								if !err
									if rotator.length > 0
										rotatorAr = []
										for article, i in rotator
											rotatorAr[i] =
												body:
													string(article.body[0].body).truncate(250).s
												author:
													article.author
												title:
													article.title
												date:
													moment(article.publishDate).format("MMMM D, YYYY")
												exactDate:
													moment(article.publishDate).toISOString().split('T')[0]
												slug:
													"/articles/#{article.slug}/"

										res.render 'index', {recentAr: recentAr, rotatorAr: rotatorAr}
									else
										res.render 'index', {recentAr: recentAr}
								else
									console.log "Error (articles): #{err}"
									res.end JSON.stringify err
						)
				else
					res.render 'errors/404', {_err: ["Article not found"]}
			else
				console.log "Error (articles): #{err}"
				res.end JSON.stringify err
	)


exports.new_get = (req,res,next) ->
	db.Sections.find().select(
		title:
			1
		slug:
			1
	).exec((err, resp) ->
		if req.session.message
			req.session.message.sections = resp

			res.render 'edit', req.session.message
			req.session.message = null
		else
			res.render 'edit', {knowsHTML: false, sections: resp, author: req.session.user.name} #fix this too
	)

exports.new_post = (req,res,next) ->
	err = []
	if !req.body.body or req.body.body.length < 3
		err.push 'Article must be longer than three characters.'

	if !req.body.title or req.body.title.length < 3
		err.push 'Title must be longer than three characters.'
	
	if !req.body.author or req.body.author.length < 3
		err.push 'Author’s name must be longer than three characters.'

	if err.length > 0
		req.session.message = req.body
		req.session.message._err = err
		req.session.message.selectedIssue = req.body.issue
		req.session.message.selectedSection = req.body.section
		req.session.message.approval =
			advisor:
				req.body.advisorapproval || 0
			administration:
				req.body.administrationapproval || 0
		res.redirect '/'
	else

		newArticle = new db.Articles
			title:
				req.body.title
			# issue:
			# 	req.body.issue #is val and not dsiplay val
			section:
				req.body.section
			author:
				req.body.author
			publishDate:
				if req.body.date then moment(req.body.date, "MM-DD-YYYY").toDate()
			lockHTML:
				string(req.body.lockHTML).toBoolean()
			createdDate:
				moment().toDate()
			status:
				req.body.status
			publication:
				2    # change to `req.body.publication` later
			approvedBy:
				advisor:
					req.body.advisorapproval || 0
				administration:
					req.body.administrationapproval || 0

		newArticle.body.unshift
			body:
				req.body.body
			editor:
				req.body.author #change later
			editDate:
				moment().toDate()

		newArticle.save (err,resp) ->
			if err == null
				res.redirect "/articles/#{resp.slug}/"
			else
	        	console.log "Error (articles): #{err}"
				res.end JSON.stringify err

exports.view = (req,res,next) ->	
	update = true
	if req.session.isUser == true then update = false
	findArticle req.params.slug, update, (err, resp) ->
		res.end 'hi'
		if !err
			if resp
				versions = []
				now = moment()

				#be smart about these when not staff later
				revbody = resp.body.slice()
				for revision, i in revbody.reverse()
					versions[i] =
						ago:
							moment.duration(moment(revision.editDate).diff(now, 'milliseconds'), 'milliseconds').humanize(true)
						editor:
							revision.editor
						num:
							i+1

				comments = []
				for comment, i in resp.staffComments
					comments[i] =
						ago:
							moment.duration(moment(comment.createdDate).diff(now, 'milliseconds'), 'milliseconds').humanize(true)
						exactDate:
							moment(revision.createdDate).toISOString()
						author:
							comment.author
						body:
							comment.body
						edited:
							comment.edited
				options = 
					body:
						resp.body[0].body
					versions:
						versions.reverse()
					resp:
						resp
					msg:
						''
					title:
						resp.title
					staff:
						req.session.isStaff || false
					comments:
						comments

				if resp.publishDate
					options.resp.date = moment(resp.publishDate).format("MMMM D, YYYY")
				else
					options.resp.date = null

				if resp.publishDate and moment(resp.publishDate) < moment()
					res.render 'article', options
				else
					if req.session.isUser
						options.msg = "This article is not yet released, you’re seeing it because you’#{if req.session.user.isStaff then "re on staff" else "ve been granted early access"}." #req.session.isStaff not true
						res.render 'article', options
					else
						# req.session.message = 'boo'
						# res.redirect '/'
						res.render 'errors/404', {err: "Article not found"}
			else
				res.render 'errors/404', {err: "Article not found"}
		else
			console.log "Error (articles): #{err}"
			res.end JSON.stringify err


exports.comment = (req,res,next) ->
	findArticle req.params.slug, false, (err, resp) ->
		if !err
			if resp
				resp.staffComments.push
					body:
						notRendered:
							req.body.body
						rendered:
							marked(req.body.body)
					author:
						req.body.author
					edited:
						string(req.body.edited).toBoolean()
					createdDate:
						moment().toDate()

				resp.save (err, resp) ->
						if err then res.end JSON.stringify err else res.redirect "/articles/#{resp.slug}/"
			else
				res.render 'errors/404', {err: "Article not found"}
		else
			console.log "Error (articles): #{err}"
			res.end JSON.stringify err


exports.edit_get = (req,res,next) ->
	db.Sections.find().select(
		title:
			1
		slug:
			1
	).exec((err, sections) ->
		req.session.message = null
		if req.session.message
			req.session.message.sections = sections

			res.render 'edit', req.session.message
		else
			findArticle req.params.slug, false, (err, article) ->
				if !err
					if article
						content =
							title:
								article.title
							author:
								article.author
							body:
								article.body[0].body
							date:
								if article.publishDate then moment(article.publishDate).format("MM-DD-YYYY")
							issue:
								article.issue
							section:
								article.section
							publication:
								article.publication
							knowsHTML:
								false
							lockHTML:
								article.lockHTML
							editing:
								true
							sections:
								sections
							# issues:
							# 	issues
							status:
								article.status || 0
							approval:
								advisor:
									article.approvedBy.advisor || 0
								administration:
									article.approvedBy.administration || 0

						res.render 'edit', content
					else
						res.render 'errors/404', {err: "Article not found"}
				else
					console.log "Error (articles): #{err}"
					res.end JSON.stringify err
	)

exports.edit_post = (req,res,next) ->
	err = []
	if !req.body.body or req.body.body.length < 3
		err.push 'Article must be longer than three characters.'

	if !req.body.title or req.body.title.length < 3
		err.push 'Title must be longer than three characters.'
	
	if !req.body.author or req.body.author.length < 3
		err.push 'Author’s name must be longer than three characters.'
	
	if err.length > 0
		req.session.message = req.body
		req.session.message._err = err
		req.session.message.selectedIssue = req.body.issue
		req.session.message.selectedSection = req.body.section
		req.session.message.approval =
			advisor:
				req.body.advisorapproval || 0
			administration:
				req.body.administrationapproval || 0
		res.redirect "/articles/#{req.params.slug}/edit"
	else
		findArticle req.params.slug, false, (err, resp) ->
			if !err
				if resp
					resp.title   =  req.body.title
					resp.author  =  req.body.author
					resp.publishDate    =  if req.body.date then moment(req.body.date, "MM-DD-YYYY").toDate()
					resp.issue   =  req.body.issue
					resp.section =  req.body.section
					resp.status  =  req.body.status
					resp.publication  =  req.body.publication
					
					resp.approvedBy=
						advisor:
							req.body.advisorapproval || resp.approvedBy.advisor || 0
						administration:
							req.body.administrationapproval || resp.approvedBy.administration || 0

					if resp.body[0].body != req.body.body
						resp.body.unshift
							body:
								req.body.body
							editor:
								req.body.author #change later
							editDate:
								moment().toDate()

					resp.save (err, resp) ->
						if err then res.end JSON.stringify err else res.redirect "/articles/#{resp.slug}/" #do not use 'is not' instead of != here


				else
					res.render 'errors/404', {err: "Article not found"}
			else
				console.log "Error (articles): #{err}"
				res.end JSON.stringify err


exports.remove = (req,res,next) ->
	if req.body.delete == "true"
		db.Articles.findOneAndRemove {
			slug: req.params.slug
		}, (err, resp) ->
			if !err
				res.redirect '/'
			else
				console.log "Error (articles): #{err}"
				res.end JSON.stringify err
	else
		res.redirect "/articles/#{resp.slug}/" 

findArticle = (slug, update = false, callback) ->
	db.Articles.findOne(
		slug:
			slug
	).select(
		publishDate:
			1
		body:
			1
		title:
			1
		author:
			1
		bodyType:
			1
		lockHTML:
			1
		status:
			1
		publication:
			1
		approvedBy:
			1
		staffComments:
			1
		views:
			1
		slug:
			1
	).exec((err, resp) ->
		if update
			resp.views++
			resp.save callback(err,resp)
		else
			callback(err,resp)
	)
	