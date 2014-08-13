db = require '../db'
moment = require 'moment'
string = require 'string'

photo_bucket_name = if process.env.NODE_ENV == 'dev' then 'torch_test' else 'torch_photos'

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
		bodyPlain:
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
	).limit(6
	).execFind(
		(err, recent) ->
			if !err
				if recent.length
					recentAr = []
					for article, i in recent
						recentAr[i] =
							body:
								string(article.bodyPlain).truncate(250).s
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
								if article.photos[0] then "http://s3.amazonaws.com/#{photo_bucket_name}/#{article._id}/#{article.photos[0].name}"
							rotator:
								if article.photos[0] then "http://s3.amazonaws.com/#{photo_bucket_name}/#{article._id}/#{article.photos[article.photos.length - 1].name}"
							isPublished:
								2
							isRotatable:
								if article.photos[0] then yes else no

					res.render 'articleList', {recentAr: recentAr, section: recent[0].section.title}
				else
					res.render 'errors/404', {_err: "This section does not have any articles"}
			else
				console.log "Error (articles): #{err}"
				res.end JSON.stringify err
	)


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
