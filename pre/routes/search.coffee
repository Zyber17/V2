db = require '../db'
es = require '../es'
moment = require 'moment'
string = require 'string'
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
			if resp && resp.hits.hits.length
				articles = []
				for article, i in resp.hits.hits
					articles[i] =
						body:
							article._source.truncated
						author:
							article._source.author
						title:
							string(article._source.title).truncate(75).s
						date:
							human:
								moment(article._source.publishDate).format("MMM D, YYYY")
							robot:
								moment(article._source.publishDate).toISOString().split('T')[0]
						slug:
							"/articles/#{article._source.slug}/"
						photo:
							if article._source.photo then "#{photo_bucket_url}#{article._id}/#{article._source.photo}"
						isPublished:
							2
				res.render 'articleList', {recentAr: articles, section: "Search: #{query}"}
			else
				res.render 'errors/404', {_err: ["No matching articles found"]}
		else
			console.log "Error (search): #{err}"
			res.end JSON.stringify err