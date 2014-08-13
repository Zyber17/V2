db = require '../../db'
moment = require 'moment'
string = require 'string'

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

				res.render 'staff/sectionsList', {sections: sections}
			else
				console.log "Error (sections): #{err}"
				res.end JSON.stringify err
	)

exports.new_get = (req,res,next) ->
	if req.session.message
		req.session.message.editing = false
		res.render 'staff/newSection', req.session.messages
		req.session.message = null
	else
		res.render 'staff/newSection', {editing: false}

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
		res.render 'staff/newSection', req.session.messages
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

					res.render 'staff/newSection', send
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
					res.render 'errors/404', {_err: "Section not found"}
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