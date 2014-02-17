totalitems = 0
item = 0

$(document).ready ->

	totalitems = parseInt $('.galleryCount').val()

	$('#prevPhoto').click ->
		prevPhoto()
		
	$('#nextPhoto').click ->
		nextPhoto()

cleanse = () ->
	$("#gallery>ul>li").removeClass 'selected'

prevPhoto = ->
	cleanse()
	item = (item-1) % totalitems
	$("#galleryLi#{item}").addClass 'selected'

nextPhoto = ->
	cleanse()
	item = (item+1) % totalitems
	$("#galleryLi#{item}").addClass 'selected'

