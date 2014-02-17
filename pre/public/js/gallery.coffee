$(document).ready ->

	totalitems = parseInt $('.galleryCount').val()

	if totalitems != 1 && totalitems != 0 && totalitems?
		item = 0

		
	else
		# console.log 'Only one item'