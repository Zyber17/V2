$(document).ready ->
	searchW = 332
	iconW = 32

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