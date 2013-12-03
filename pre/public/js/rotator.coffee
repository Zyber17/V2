$(document).ready ->
	item = 0;
	$('#rotator').hover(
		->
			clearTimeout window.doRotate
			
			$('.recentPre li').hover ->
				item = $(@).attr('data-index')
				select()
		,->
			window.doRotate = setTimeout(
				->
					rotate()
				,10000
			)
	)

	select = () ->
		cleanse()
		$("#ritem#{item}").addClass 'selected'
		$("#sitem#{item}").addClass 'selected'
		$("#titem#{item}").addClass 'selected'

	cleanse = () ->
		$(".img>ul>li").removeClass 'selected'
		$(".recentPre>ul>li").removeClass 'selected'
		$(".text>ul>li").removeClass 'selected'

	rotate = () ->
		item = (item+1) % 3
		select()
		window.doRotate = setTimeout(
			->
				rotate()
			,7000
		)



	window.doRotate = setTimeout(
		->
			rotate()
		,10000
	)