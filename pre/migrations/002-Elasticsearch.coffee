db = require '../db'
es = require '../es'
string = require 'string'
moment = require 'moment'

up = () ->
	db.Articles.find({publishDate:
			$lte:
				moment().toDate()
		status:
			4}).select({bodyPlain: 1, title: 1, slug: 1, photos: 1, author: 1, publishDate: 1}).exec(
		(err, articles) ->
			if !err
				if articles.length
					for article, i in articles
						if article?
							if article.bodyPlain? && article.title? && article.slug?
								es.index {
									index: 'torch',
									type: 'article',
									id: article._id.toString()
									body: {
										title: article.title
										author: article.author
										date: article.publishDate
										slug: article.slug
										photo: if article.photos[0] then (if article.photos.length > 1 then article.photos[article.photos.length - 2].name else article.photos[0].name)
										body: article.bodyPlain
										truncated: string(article.bodyPlain).truncate(400).s
									}
								}, (err,esresp) ->
									if !err
										console.log "Okay: #{i}"
									else
										console.log "Error (Migration 002): #{err}"
										return
			else
				console.log "Error: #{err}"
				return
	)

up()