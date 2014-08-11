db = require '../db'
moment = require 'moment'
string = require 'string'
photo_bucket_name = if process.env.NODE_ENV == 'dev' then 'torch_test' else 'torch_photos'
photo_bucket_url = "http://s3.amazonaws.com/#{photo_bucket_name}/"

exports.index = (req,res,next) ->
	db.Articles.find(
		{publishDate:
			$lte:
				moment().toDate()
		status:
			4},
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
			1}
	).sort({'publishDate':-1, 'lastEditDate': -1}
	).limit(6
	).execFind(
		(err, recent) ->
			if !err
				if recent.length
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
									moment(article.publishDate).format("MMM D, YYYY")
								robot:
									moment(article.publishDate).toISOString().split('T')[0]
							slug:
								"/articles/#{article.slug}/"
							section:
								JSON.stringify(article.section)
							photo:
								if article.photos[0] then (photo_bucket_url + article._id + '/' + if article.photos.length > 1 then article.photos[article.photos.length - 2].name else article.photos[0].name)
							rotator:
								if article.photos[0] then photo_bucket_url + article._id + '/' + article.photos[article.photos.length - 1].name
							isPublished:
								2 #harcoded becase all artices returned this way will be pushed, which is a status of 2
							isRotatable:
								if article.photos[0] then yes else no

					res.render 'index', {recentAr: recentAr}

					# This will happen late when I have time and stuff yeah that jazzy
					# db.Articles.find(
					# 	{publishDate:
					# 		$lte:
					# 			moment().toDate()
					# 	status:
					# 		4
					# 	isRotator:
					# 		true},
					# 	{publishDate:
					# 		1
					# 	body:
					# 		1
					# 	title:
					# 		1
					# 	author:
					# 		1
					# 	slug:
					# 		1}
					# ).sort('-publishDate'
					# ).limit(4
					# ).execFind(
					# 	(err, rotator) ->
					# 		if !err
					# 			if rotator.length > 0
					# 				rotatorAr = []
					# 				for article, i in rotator
					# 					rotatorAr[i] =
					# 						body:
					# 							string(htmlToText.fromString(article.body[0].body)).truncate(250).s
					# 						author:
					# 							article.author
					# 						title:
					# 							string(article.title).truncate(75).s
					# 						date:
					# 							human:
					# 								moment(article.publishDate).format("MMM D, YYYY")
					# 							robot:
					# 								moment(article.publishDate).toISOString().split('T')[0]
					# 						slug:
					# 							"/articles/#{article.slug}/"

					# 				res.render 'index', {recentAr: recentAr, rotatorAr: rotatorAr}
					# 			else
					# 				res.render 'index', {recentAr: recentAr}
					# 		else
					# 			console.log "Error (articles): #{err}"
					# 			res.end JSON.stringify err
					# )
				else
					res.render 'errors/404', {_err: ["Article not found"]}
			else
				console.log "Error (articles): #{err}"
				res.end JSON.stringify err
	)


exports.json = (req,res,next) ->
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
			1
		photos:
			1
		_id:
			0}
	).sort({'publishDate':-1, 'lastEditDate': -1}
	).limit(10
	).execFind(
		(err, recent) ->
			if !err
				if recent.length
					for article, i in recent
						recent[i].body.slice(0)
					res.json recent
				else
					res.render 'errors/404', {_err: ["Article not found"]}
			else
				console.log "Error (articles): #{err}"
				res.end JSON.stringify err
	)

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

				isGallery = if resp.isGallery && resp.photos[0] then true else false
				if isGallery
					galleryUrls = []
					for photo in resp.photos
						galleryUrls.push photo_bucket_url + resp._id + '/' + photo.name
				
				options = 
					body:
						resp.body[0].body
					versions:
						versions.reverse()
					resp:
						resp
					date:
						human:
							if resp.publishDate then moment(resp.publishDate).format("MMM D, YYYY")
						robot:
							if resp.publishDate then moment(resp.publishDate).toISOString().split('T')[0]
					msg:
						null
					title:
						resp.title
					staff:
						req.session.isStaff || false
					comments:
						comments
					photo:
						if resp.photos[0] then (photo_bucket_url + resp._id + '/' + if resp.photos.length > 1 then resp.photos[resp.photos.length - 2].name else resp.photos[0].name)
					section:
						resp.section
					isGallery:
						if isGallery then resp.isGallery else false
					galleryItems:
 						if isGallery then galleryUrls else null
					isVideo:
						if resp.isVideo then resp.isVideo else false
					videoEmebed:
						if resp.videoEmebed then resp.videoEmebed else null

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
						res.render 'errors/404', {err: "Article not found"}
			else
				res.render 'errors/404', {err: "Article not found"}
		else
			console.log "Error (articles): #{err}"
			res.end JSON.stringify err



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