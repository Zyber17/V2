db = require '../db'
es = require '../es'
htmlToText = require 'html-to-text'

up = () ->
	db.Articles.find().select({body: 1, title: 1, slug: 1}).exec(
		(err, articles) ->
			if !err
				if articles.length
					for article, i in articles
						if article?
							if article.body?
								if article.body[0]?
									if article.body[0].body?
										# console.log JSON.stringify article
										plain = (htmlToText.fromString(article.body[0].body)).toString()
										es.index {
											index: 'torch',
											type: 'article',
											body: {
												title: article.title
												body: plain
												slug: article.slug
											}
										}, (err,esresp) ->
											if !err
												article.bodyPlain = plain
												article.save (err, resp) ->
													if !err
														console.log JSON.stringify esresp
														console.log "Okay: #{i}"
													else
														console.log "Error (articles): #{err}"
														return
											else
												console.log "Error (articles): #{err}"
												return
			else
				console.log "Error (articles): #{err}"
				return
	)

up()