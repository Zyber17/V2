RSS = require "rss"
moment = require "moment"
db = require "../db"

module.exports = (req,res,next) ->
	feed = new RSS
		title:
			"Pine View Torch"

		description:
			"The Torch is a student newspaper, distributed at Pine View School in Osprey, Florida."
		
		feed_url:
			"http://pineviewtorch.com/rss"
		
		site_url:
			"http://pineviewtorch.com/"

		###
			Fix this later
			image_url:
				"http://pineviewtorch.com/TBD.image"
		###

		author:
			"Pine View Torch"

		webMaster:
			'Zackary Corbett'

		copyright:
			"#{new Date().getFullYear()} Pine View Torch"

		language:
			'en'

	db.Articles.find(
		{publishDate:
			$lte:
				moment().toDate()
		status:
			4},
		{publishDate:
			1
		body:
			1
		title:
			1
		author:
			1
		slug:
			1}
	).sort('-publishDate'
	).limit(15
	).execFind(
		(err, resp) ->
			if !err
				if resp
					for article in resp
						feed.item		
							title:
								article.title

							description:
								article.body[0].body

							url:
								"http://pineviewtorch.com/articles/#{article.slug}"

							guid:
								article._id.toString()

							author:
								article.author

							date:
								article.publishDate

					res.end feed.xml()
				else
					res.render 'errors/404', {err: "Page not found"}
			else
				console.log "Error (rss): #{err}"
				res.end JSON.stringify err
	)