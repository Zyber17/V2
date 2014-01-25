db = require '../db'
moment = require 'moment'
htmlToText = require 'html-to-text'
# marked = require 'marked'
string = require 'string'
# string = require 'string'

exports.view = (req,res,next) ->
	db.Articles.find(
		{publishDate:
			$lte:
				moment().toDate()
		status:
			4
		'section.slug':
			req.params.slug},
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
		section:
			1}
	).sort({'publishDate':-1, 'lastEditDate': -1}
	).limit(3
	).execFind(
		(err, recent) ->
			if !err
				if recent.length
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
									moment(article.publishDate).format("MMM D, YYYY")
								robot:
									moment(article.publishDate).toISOString().split('T')[0]
							slug:
								"/articles/#{article.slug}/"
							section:
								JSON.stringify(article.section)
							photo:
								if article.photos[0] then "http://s3.amazonaws.com/V2_test/#{article._id}/#{article.photos[0].name}"
							rotator:
								if article.photos[0] then "http://s3.amazonaws.com/V2_test/#{article._id}/#{article.photos[article.photos.length - 1].name}"

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


exports.list = (req,res,next) ->
	db.Sections.find(
		{},
		{title:
			1
		slug:
			1}
	).sort('-createdDate'
	).execFind(
		(err, resp) ->
			if !err
				sections = []
				for section, i in resp
					sections[i] =
						title:
							section.title
						slug:
							"/staff/sections/#{section.slug}/"

				res.render 'sectionsList', {sections: sections}
			else
				console.log "Error (sections): #{err}"
				res.end JSON.stringify err
	)

exports.new_get = (req,res,next) ->
	if req.session.message
		req.session.message.editing = false
		res.render 'newSection', req.session.messages
		req.session.message = null
	else
		res.render 'newSection', {editing: false}

exports.new_post = (req,res,next) ->
	err = []
	if !req.body.title or req.body.title.length < 3
		err.push "Name must be three characters or more."

	if err.length > 0
		req.session.message = req.body
		req.session.message._err = err
		res.redirect '/staff/sections/new'
	else
		newSection = new db.Sections
			title:
				req.body.title

		newSection.save (err,resp) ->
			if !err
				res.redirect '/staff/sections/'
			else
				console.log "Error (sections): #{err}"
				res.end JSON.stringify err

exports.edit_get = (req,res,next) ->
	if req.session.message
		req.session.message.editing = true
		res.render 'newSection', req.session.messages
		req.session.message = null
	else
		findSection req.params.slug, (err,resp) ->
			if !err
				if resp
					send=
						title:
							resp.title
						editing:
							true

					res.render 'newSection', send
				else
					res.render 'errors/404', {_err: "Section not found"}
			else
				console.log "Error (sections): #{err}"
				res.end JSON.stringify err

exports.edit_post = (req,res,next) ->
	err = []
	if !req.body.title or req.body.title.length < 3
		err.push "Name must be three characters or more."

	if err.length > 0
		req.session.message = req.body
		req.session.message._err = err
		res.redirect "/staff/sections/#{req.params.slug}"
	else
		findSection req.params.slug, (err,resp) ->
			if !err
				if resp
					resp.title = req.body.title

					resp.save (err, resp) ->
						if err
							console.log "Error (sections): #{err}"
							res.end JSON.stringify err
						else res.redirect "/staff/sections/"
				else
					res.render 'errors/404', {_err: "Article not found"}
			else
				console.log "Error (sections): #{err}"
				res.end JSON.stringify err

exports.remove = (req,res,next) ->
	db.Sections.findOneAndRemove {
		slug: req.params.slug
	}, (err, resp) ->
		if !err
			res.redirect '/staff/sections/'
		else
			console.log "Error (sections): #{err}"
			res.end JSON.stringify err


findSection = (slug, callback) ->
	db.Sections.findOne(
		slug:
			slug
	).select(
		title:
			1
		slug:
			1
	).exec((err, resp) ->
		callback(err,resp)
	)