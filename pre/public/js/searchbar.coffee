$(document).ready ->
	searchW = 340
	iconW = 44

	entFullW = 208
	entSmallW = 53

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

	$('#entertainment')
		.mouseenter () ->
			$('#entertainment a .hide').stop().animate {
				width: entFullW
			}
		.mouseleave () ->
			$('#entertainment a .hide').stop().animate {
				width: entSmallW
			}