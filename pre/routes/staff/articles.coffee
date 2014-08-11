db = require '../../db'
es = require '../../es'
moment = require 'moment'
marked = require 'marked'
string = require 'string'
htmlToText = require 'html-to-text'
photo_bucket_name = if process.env.NODE_ENV == 'dev' then 'torch_test' else "torch_photos"

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
		{},
		{publishDate:
			1
		truncated:
			1
		title:
			1
		author:
			1
		slug:
			1
		photos:
			1
		status:
			1
		createdDate:
			1}
	).sort({'createdDate':-1}
	).limit(30
	).execFind(
		(err, recent) ->
			if !err
				if recent.length && recent?
					recentAr = []
					for article, i in recent
						recentAr[i] =
							body:
								article.truncated
							author:
								article.author
							title:
								string(article.title).truncate(75).s
							date:
								human:
									if article.publishDate then moment(article.publishDate).format("MMM D, YYYY")
								robot:
									if article.publishDate then moment(article.publishDate).toISOString().split('T')[0]
							slug:
								"/staff/articles/#{article.slug}/"
							section:
								JSON.stringify(article.section)
							photo:
								if article.photos[0] then "http://s3.amazonaws.com/#{photo_bucket_name}/#{article._id}/#{article.photos[0].name}"
							isPublished:
								if article.status == 4 && article.publishDate then (if moment(article.publishDate) < moment() then 2 else 1) else 0
							isRotatable:
								if article.photos[0] then yes else no

					res.render 'articleList', {recentAr: recentAr, section: "All Stories"}

				else
					res.render 'errors/404', {_err: ["Article not found"]}
			else
				console.log "Error (staff/articles): #{err}"
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

			res.render 'staff/edit', req.session.message
			req.session.message = null
		else
			res.render 'staff/edit', {knowsHTML: false, sections: resp, author: req.session.user.name} #fix this too
	)

exports.new_post = (req,res,next) ->
	err = []
	if !req.body.body or req.body.body.length < 3
		err.push 'Article must be longer than three characters.'

	if !req.body.title or req.body.title.length < 3
		err.pu
		sh 'Title must be longer than three characters.'
	
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
		findSection req.body.section,(err,resp) ->
			if !err
				if resp
					newArticle = new db.Articles
						title:
							req.body.title
						section:
							title:
								resp.title
							slug:
								resp.slug
							id:
								resp._id
						bodyPlain:
							htmlToText.fromString(req.body.body)
						truncated:
							string(htmlToText.fromString(req.body.body)).truncate(400).s
						author:
							req.body.author
						publishDate:
							if req.body.date then moment(req.body.date, "MM-DD-YYYY").toDate()
						lastEditDate:
							moment().toDate()
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
						isGallery:
							req.body.isGallery
						isVideo:
							req.body.isVideo
						videoEmebed:
							if req.body.videoEmebed then req.body.videoEmebed else ''

					newArticle.body.unshift
						body:
							req.body.body
						editor:
							req.session.user.name
						editDate:
							moment().toDate()

					newArticle.save (err,resp) ->
						if err == null
							if resp.status == 4 && moment().toDate() > resp.publishDate
								es.index {
									index: 'torch',
									type: 'article',
									id: resp._id.toString()
									body: {
										title: resp.title
										author: resp.author
										date: resp.publishDate
										slug: resp.slug
										photo: if resp.photos[0] then (if resp.photos.length > 1 then resp.photos[resp.photos.length - 2].name else resp.photos[0].name)
										body: resp.bodyPlain
										truncated: string(resp.bodyPlain).truncate(400).s
									}
								}, (err,esresp) ->
									if err
										console.log "Error (Articles, es-add): #{err}"
										res.end JSON.stringify err
										return
								res.redirect "/staff/articles/#{resp.slug}/"
							else
								res.redirect "/staff/articles/#{resp.slug}/"
						else
				        	console.log "Error (articles): #{err}"
							res.end JSON.stringify err
				else
					res.render 'errors/404', {err: "Section not found"}
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
						if err then res.end JSON.stringify err else res.redirect "/staff/articles/#{resp.slug}/"
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

			res.render 'staff/edit', req.session.message
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
							isGallery:
								article.isGallery
							isVideo:
								article.isVideo
							videoEmebed:
								article.videoEmebed
							# issues:
							# 	issues
							status:
								article.status || 0
							approval:
								advisor:
									article.approvedBy.advisor || 0
								administration:
									article.approvedBy.administration || 0

						res.render 'staff/edit', content
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
		res.redirect "/staff/articles/#{req.params.slug}/edit"
	else
		findArticle req.params.slug, false, (err, resp) ->
			if !err
				if resp
					findSection req.body.section, (err,section_resp) ->
						if !err
							if section_resp
								oldStatus = resp.status
								oldPublishdate = resp.publishDate

								resp.title   =  req.body.title
								resp.author  =  req.body.author
								resp.bodyPlain	=  htmlToText.fromString(req.body.body)
								resp.truncated	=  string(htmlToText.fromString(req.body.body)).truncate(400).s
								resp.publishDate    =  if req.body.date then moment(req.body.date, "MM-DD-YYYY").toDate()
								resp.issue   =  req.body.issue
								resp.status  =  req.body.status
								resp.publication  =  req.body.publication
								resp.lastEditDate = moment().toDate()
								resp.isGallery = req.body.isGallery
								resp.isVideo = req.body.isVideo
								resp.videoEmebed = if req.body.videoEmebed then req.body.videoEmebed else ''

								
								resp.section =
									title:
										section_resp.title
									slug:
										section_resp.slug
									id:
										section_resp._id

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
											req.session.user.name
										editDate:
											moment().toDate()

								resp.save (err, resp) ->
									if (resp.status == 4 && moment().toDate() > resp.publishDate) && (oldStatus != 4 || moment().toDate() < oldPublishdate || !oldPublishdate)
										es.index {
											index: 'torch',
											type: 'article',
											id: resp._id.toString()
											body: {
												title: resp.title
												author: resp.author
												date: resp.publishDate
												slug: resp.slug
												photo: if resp.photos[0] then (if resp.photos.length > 1 then resp.photos[resp.photos.length - 2].name else resp.photos[0].name)
												body: resp.bodyPlain
												truncated: string(resp.bodyPlain).truncate(400).s
											}
										}, (err,esresp) ->
											if err
												console.log "Error (Articles, es-add): #{err}"
												res.end JSON.stringify err
												return
										res.redirect "/staff/articles/#{resp.slug}/"
									else if resp.status == 4 && oldStatus == 4 && moment().toDate() > resp.publishDate && moment().toDate() > oldPublishdate
										es.update {
											index: 'torch',
											type: 'article',
											id: resp._id.toString(),
											body: {
												doc: {
													title: resp.title
													author: resp.author
													date: resp.publishDate
													slug: resp.slug
													photo: if resp.photos[0] then (if resp.photos.length > 1 then resp.photos[resp.photos.length - 2].name else resp.photos[0].name)
													body: resp.bodyPlain
													truncated: string(resp.bodyPlain).truncate(400).s
												}
											}
										}, (err,esresp) ->
											if !err
												res.redirect "/staff/articles/#{resp.slug}/"
											else
												console.log "Error (Articles, es-update): #{err}"
												res.end JSON.stringify err
									else if (oldStatus == 4 && resp.status != 4) || (moment().toDate() < resp.publishDate && oldPublishdate < moment().toDate())
										es.delete {
											index: 'torch',
											type: 'article',
											id: resp._id.toString()
										}, (err,esresp) ->
											if !err
												res.redirect "/staff/articles/#{resp.slug}/"
											else
												console.log "Error (Articles, es-delete): #{err}"
												res.end JSON.stringify err
									else
										console.log "(Articles ~400): This should never happen"
										res.end "(Articles ~400): This should never happen"
							else
								res.render 'errors/404', {err: "Section not found"}
						else
							console.log "Error (articles): #{err}"
							res.end JSON.stringify err
				else
					res.render 'errors/404', {err: "Article not found"}
			else
				console.log "Error (articles): #{err}"
				res.end JSON.stringify err
			


exports.remove = (req,res,next) ->
	if req.body.delete == "true"
		db.Articles.findOne {
			slug: req.params.slug
		}, (err, resp) ->
			if !err
				es.delete {
					index: 'torch',
					type: 'article',
					id: resp._id.toString()
				}, (err,esresp) ->
					if !err
						resp.remove (err,resp) ->
							if !err
								res.redirect "/staff/articles/"
							else
								console.log "Error (articles-delete): #{err}"
								res.end JSON.stringify err
					else
						console.log "Error (Articles, es-delete): #{err}"
						res.end JSON.stringify err
			else
				console.log "Error (articles-delete): #{err}"
				res.end JSON.stringify err
	else
		res.redirect "/staff/articles/#{resp.slug}/"

exports.removePhotos = (req,res,next) ->
	# Removes DB recods of a photo, but does not remove the photo itself from S3
	if req.body.photosDelete == "true"
		db.Articles.findOne {
			slug: req.params.slug
		}, (err, resp) ->
			if !err
				if resp
					resp.photos = []
					resp.save (err, resp) ->
						if !err
							res.redirect "/staff/articles/#{resp.slug}/" 
						else
							console.log "Error (articles): #{err}"
							res.end JSON.stringify err

				else
					res.render 'errors/404', {err: "Not found"}	
			else
				console.log "Error (articles): #{err}"
				res.end JSON.stringify err
	else
		res.redirect "/staff/articles/#{resp.slug}/" 


findArticle = (slug, update = false, callback) ->
	db.Articles.findOne(
		slug:
			slug
	).select(
		publishDate:
			1
		body:
			1
		truncated:
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
		photos:
			1
		section:
			1
		isGallery:
			1
		isVideo:
			1
		videoEmebed:
			1
	).exec((err, resp) ->
		if update
			resp.views++
			resp.save callback(err,resp)
		else
			callback(err,resp)
	)

findSection = (id,callback) ->
	db.Sections.findOne(
		_id:
			id
	).select(
		title:
			1
		slug:
			1
	).exec((err, resp) ->
		callback(err,resp)
	)