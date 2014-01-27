$(document).ready ->

	totalitems = parseInt $('.rotatorCount').val()

	if totalitems != 1 && totalitems != 0 && totalitems?
		item = 0

		$('#rotator').hover(
			->
				clearTimeout window.doRotate
				# console.log 'Hovered'
				
				$('.recentPre li').hover ->
					item = $(@).attr('data-index')
					select()
			,->
				window.doRotate = setTimeout(
					->
						rotate()
						# console.log 'Rotating'
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
			item = (item+1) % totalitems
			select()
			window.doRotate = setTimeout(
				->
					rotate()
					# console.log 'Rotating'
				,7000
			)



		window.doRotate = setTimeout(
			->
				rotate()
				# console.log 'Rotating'
			,10000
		)
	else
		# console.log 'Only one item'