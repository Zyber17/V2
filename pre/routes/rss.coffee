rss = require "rss"

exports.rss = (req,res,next) ->
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

	#add DB intregration later
	feed.item
		title:
			item.title

		descripton:
			item.content

		url:
			"http:/pineviewtorch.com/#{item.slug}"

		guid:
			item.id

		auhtor:
			item.author

		date:
			item.date.rss

	res.end feed.xml()