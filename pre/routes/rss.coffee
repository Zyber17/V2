rss = require "rss"

feed = new RSS {
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

}

items.forEach (item) ->
	feed.item {
		title:
			item.title
		# "description" may be called "content" in a future release
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
			# Should be formatted in RFC 822, like "Sat, 07 Sep 2002 0:00:01 GMT", see: http://feed2.w3.org/docs/rss2.html
	}

# Do something with this eventually
xml = feed.xml()