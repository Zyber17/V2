$(document).ready ->
	searchW = 340
	iconW = 44

	entFullW = 376
	entSmallW = 69
	margin = 17

	if($('#searchbox').val() != '')
		$('#search').css('width', searchW)

	$('#search')
		.mouseenter () ->
			$(@).stop().animate {
				width: searchW
			}
		.mouseleave () ->
			if $('#searchbox').val() == '' && !$('#searchbox').is(':focus')
				$(@).stop().animate {
					width: iconW
				}

	$('#searchbox').blur () ->
		if $('#searchbox').val() == '' && !$('#search').is(':hover')
			$('#search').stop().animate {
				width: iconW
			}

	$('#ent_focus')
		.mouseenter () ->
			$('#ent_focus .hidewrapper').stop().animate {
				width:
					entFullW
				"margin-right":
					0
			}
		.mouseleave () ->
			$('#ent_focus .hidewrapper').stop().animate {
				width:
					entSmallW
				"margin-right":
					margin
			}