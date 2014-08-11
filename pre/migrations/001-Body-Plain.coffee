db = require '../db'
htmlToText = require 'html-to-text'
string = require 'string'

up = () ->
	db.Articles.find().select({body: 1, title: 1}).exec(
		(err, articles) ->
			if !err
				if articles.length
					for article, i in articles
						if article?
							if article.body?
								if article.body[0]?
									if article.body[0].body?
										#console.log JSON.stringify article
										article.bodyPlain = (htmlToText.fromString(article.body[0].body)).toString()
										article.truncated = string(htmlToText.fromString(article.body[0].body)).truncate(400).s
										article.save (err, resp) ->
											console.log(if err then JSON.stringify err else "Okay: #{i}")
			else
				console.log "Error (Migration 001): #{err}"
				return
	)

up()