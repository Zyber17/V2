db = require '../db'
moment = require 'moment'
# string = require 'string'

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
							"/sections/#{section.slug}/"

				res.render 'sectionsList', {sections: sections}
			else
				console.log err
				res.end JSON.stringify err
	)

exports.new_get = (req,res,next) ->
	if req.session.message
		send=
			err:
				req.session.message.err
			title:
				req.session.message.content.title
			editing:
				false
		res.render 'newSection', send
	else
		res.render 'newSection', {editing: false}

exports.new_post = (req,res,next) ->
	err = []
	if !req.body.title or req.body.title.length < 3
		err.push "Name must be three characters or more."

	if err.length > 0
		req.session.message
			err:
				err
			content:
				req.body
		res.redirect '/sections/new'
	else
		newSection = new db.Sections
			title:
				req.body.title

		newSection.save (err,resp) ->
			if !err
				res.redirect '/sections/'
			else
				res.end JSON.stringify err

exports.edit_get = (req,res,next) ->
	if req.session.message
		send=
			err:
				req.session.message.err
			title:
				req.session.message.content.title
			editing:
				true
		res.render 'newSection', send
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
					res.render 'errors/404', {err: "Section not found"}
			else
				console.log err
				res.end JSON.stringify err

exports.edit_post = (req,res,next) ->
	err = []
	if !req.body.title or req.body.title.length < 3
		err.push "Name must be three characters or more."

	if err.length > 0
		req.session.message
			err:
				err
			content:
				req.body
		res.redirect "/sections/#{req.params.slug}"
	else
		findSection req.params.slug, (err,resp) ->
			if !err
				if resp
					resp.title = req.body.title

					resp.save (err, resp) ->
						if err then res.end JSON.stringify err else res.redirect "/sections/"
				else
					res.render 'errors/404', {err: "Article not found"}
			else
				console.log err
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