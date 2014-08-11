db = require '../db'
es = require '../es'
moment = require 'moment'
marked = require 'marked'
string = require 'string'
htmlToText = require 'html-to-text'
photo_bucket_name = if process.env.NODE_ENV == 'dev' then 'torch_test' else "torch_photos"
photo_bucket_url = "http://s3.amazonaws.com/#{photo_bucket_name}/"


exports.searchDirector = (req,res,next) ->
	if req.query.q?
		searchGet(req,res,next)
	else
		searchView(req,res,next)

searchView = (req,res,next) ->
	res.render 'search'

searchGet = (req,res,next) ->
	query = decodeURIComponent(req.query.q)
	es.search {
		index: 'torch'
		type: 'article'
		q: query
	}, (err,resp) ->
		if !err
			res.end JSON.stringify resp
		else
			console.log JSON.stringify err