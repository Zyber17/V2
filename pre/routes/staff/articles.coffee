db = require '../../db'
moment = require 'moment'
marked = require 'marked'
string = require 'string'
htmlToText = require 'html-to-text'
photo_bucket_name = "torch_photos"

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
		status:
			1}
	).sort({'publishDate':-1, 'lastEditDate': -1}
	).limit(30
	).execFind(
		(err, recent) ->
			if !err
				if recent.length && recent?
					recentAr = []
					for article, i in recent
						recentAr[i] =
							body:
								string(htmlToText.fromString(article.body[0].body)).truncate(250).s
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
								"/articles/#{article.slug}/"
							section:
								JSON.stringify(article.section)
							photo:
								if article.photos[0] then "http://s3.amazonaws.com/#{photo_bucket_name}/#{article._id}/#{article.photos[0].name}"
							isPublished:
								if article.status == 4 && article.publishDate then (if moment(article.publishDate) < moment() then 2 else 1) else 0

					res.render 'index', {recentAr: recentAr, isStaffView: true}

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
				console.log "Error (staff/articles): #{err}"
				res.end JSON.stringify err
	)



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
		photos:
			1
		section:
			1
	).exec((err, resp) ->
		if update
			resp.views++
			resp.save callback(err,resp)
		else
			callback(err,resp)
	)