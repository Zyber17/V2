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
	).limit(10
	).execFind(
		(err, resp) ->
			articles = []
			for article, i in resp
				articles[i] =
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

			res.render 'index', {articles: articles}
	)


exports.create = (req,res,next) ->
	sections =
			list:[
				{_id:'jkdf33', name: 'Studient Life'}
				{_id: 'ieuhrg76', name: 'Science'}]
			selected: null

		issues =
			list:[
				{_id:'sdsdv', name: 'Just 2012'}
				{_id: 'ffffefe', name: 'Web'}]
			selected: null
	if req.session.message
		issues.selected = req.session.message.content.issue
		sections.selected = req.session.message.content.section


		resp =
			err:
				req.session.message.reason
			title:
				req.session.message.content.title
			body:
				req.session.message.content.body
			date:
				req.session.message.content.date
			author:
				req.session.message.content.author
			status:
				req.session.message.content.status
			publication:
				req.session.message.content.publication
			approval:
				advisor:
					0
				administration:
					0
			editing:
				false
			lockHTML:
				req.session.message.content.lockHTML
			knowsHTML:
				true #fix this
			sections:
				sections
			issues:
				issues

		if req.session.message.content.approval
			resp.approval.advisor = req.session.message.content.approval.advisor || 0
			resp.approval.administration = req.session.message.content.approval.administration || 0

		res.render 'edit', resp
		req.session.message = null
	else
		
		res.render 'edit', {knowsHTML: false, sections: sections, issues: issues} #fix this too

exports.add = (req,res,next) ->
	err = []
	if !req.body.body or req.body.body.length < 3
		err.push 'Article must be longer than three characters.'

	if !req.body.title or req.body.title.length < 3
		err.push 'Title must be longer than three characters.'
	
	if !req.body.author or req.body.author.length < 3
		err.push 'Author’s name must be longer than three characters.'

	if err.length > 0
		req.session.message =
			reason:
				err
			content:
				title:
					req.body.title
				author:
					req.body.author
				lockHTML:
					string(req.body.lockHTML).toBoolean()
				body:
					req.body.body
				date:
					req.body.date
				issue:
					req.body.issue
				section:
					req.body.section
				status:
					req.body.status
				publication:
					req.body.publication
				approval:
					advisor:
						req.body.advisorapproval || null
					administration:
						req.body.administrationapproval || null
		res.redirect '/'
	else

		newArticle = new db.Articles
			title:
				req.body.title
			# issue:
			# 	req.body.issue #is val and not dsiplay val
			# section:
			# 	req.body.section
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
				req.body.publication
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
	        	console.log err
				res.end JSON.stringify err

exports.get = (req,res,next) ->	
	update = true
	#if req.session.staff is true then update is false
	findArticle req.params.slug, update, (err, resp) ->
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
						true
					comments:
						comments

				if resp.publishDate
					options.resp.date = moment(resp.publishDate).format("MMMM D, YYYY")
				else
					options.resp.date = null

				if options.resp.date and options.resp.date < moment()
					res.render 'article', options
				else
					if true #req.session.user
						options.msg = "This article is not yet released, you’re seeing it because you’#{if true then "re on staff" else "ve been granted early access"}." #req.session.isStaff not true
						res.render 'article', options
					else
						# req.session.message = 'boo'
						# res.redirect '/'
						res.render 'errors/404', {err: "Article not found"}
			else
				res.render 'errors/404', {err: "Article not found"}
		else
			console.log err
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
			console.log err
			res.end JSON.stringify err


exports.edit_get = (req,res,next) ->
	if req.session.message
		resp =
			err:
				req.session.message.reason
			title:
				req.session.message.content.title
			body:
				req.session.message.content.body
			date:
				req.session.message.content.date
			issue:
				req.session.message.content.issue
			section:
				req.session.message.content.section
			editing:
				false
			lockHTML:
				req.session.message.content.lockHTML
			status:
				req.session.message.content.status
			publication:
				req.session.message.content.publication
			approval:
				advisor:
					req.session.message.content.approval.advisor
				administration:
					req.session.message.content.approval.administration

		res.render 'edit', resp
		req.session.message = null
	else
		findArticle req.params.slug, false, (err, resp) ->
			if !err
				if resp
					content =
						title:
							resp.title
						author:
							resp.author
						body:
							resp.body[0].body
						date:
							if resp.publishDate then moment(resp.publishDate).format("MM-DD-YYYY")
						issue:
							resp.issue
						section:
							resp.section
						publication:
							resp.publication
						knowsHTML:
							true
						lockHTML:
							resp.lockHTML
						editing:
							true
						sections:
							list:[
								{_id:'jkdf33', name: 'Studient Life'}
								{_id: 'ieuhrg76', name: 'Science'}]
							selected: null
						issues:
							list:[
								{_id:'sdsdv', name: 'Just 2012'}
								{_id: 'ffffefe', name: 'Web'}]
							selected: null
						status:
							resp.status || 0
						approval:
							advisor:
								resp.approvedBy.advisor || 0
							administration:
								resp.approvedBy.administration || 0

					res.render 'edit', content
				else
					res.render 'errors/404', {err: "Article not found"}
			else
				console.log err
				res.end JSON.stringify err


exports.edit_post = (req,res,next) ->
	err = []
	if !req.body.body or req.body.body.length < 3
		err.push 'Article must be longer than three characters.'

	if !req.body.title or req.body.title.length < 3
		err.push 'Title must be longer than three characters.'
	
	if !req.body.author or req.body.author.length < 3
		err.push 'Author’s name must be longer than three characters.'
	
	if err.length > 0
		req.session.message =
			reason:
				err
			content:
				title:
					req.body.title
				author:
					req.body.author
				body:
					req.body.body
				date:
					req.body.date
				issue:
					req.body.issue
				section:
					req.body.section
				publication:
					req.body.publication
				approval:
					advisor:
						req.body.advisorapproval || null
					administration:
						req.body.administrationapproval || null
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
				console.log err
				res.end JSON.stringify err


exports.remove = (req,res,next) ->
	if req.body.delete == "true"
		db.Articles.findOneAndRemove {
			slug: req.params.slug
		}, (err, resp) ->
			if !err
				res.redirect '/'
			else
				console.log err
				res.end JSON.stringify err
	else
		res.redirect "/articles/#{resp.slug}/" 

findArticle = (slug, update, callback) ->
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
	