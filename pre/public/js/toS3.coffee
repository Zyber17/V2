#http://www.ioncannon.net/programming/1539/direct-browser-uploading-amazon-s3-cors-fileapi-xhr2-and-signed-puts/
total = null
done = null
killed = null
createCORSRequest = (method, url)  ->
	xhr = new XMLHttpRequest()

	if "withCredentials" in xhr
		xhr.open method, url, true

	else if typeof XDomainRequest != "undefined"
		xhr = new XDomainRequest()
		xhr.open method, url

	else
		xhr = null

	return xhr
 
handleFileSelect = (e) ->
	total = 0
	done = 0
	killed = 0
	setProgress 0, 'Upload started.'
 
	files = document.getElementById("files").files
 
	output = []
	for file, i in files
		uploadFile file, i

	total = i
 
###
	Execute the given callback with the signed response.
###
executeOnSignedUrl = (file, i, callback) ->
	xhr = new XMLHttpRequest()
	xhr.open 'GET', "signS3/#{file.type}?noCacheingPlease=#{encodeURIComponent(file.name)}", true
 
	#Hack to pass bytes through unprocessed.
	xhr.overrideMimeType 'text/plain; charset=x-user-defined'
 
	xhr.onreadystatechange = (e) ->
		if @readyState == 4 and @status == 200
			callback @responseText

		else if @readyState == 4 and @status != 200
			if @status == 403
				++killed
				if @responseText = "Invalid mime"
					alert "#{file.name} is not an image (png, jpg, jpeg, gif)."

			else
				setProgress 0, "Could not contact signing script. Status = #{@status}"
	xhr.send()

 
uploadFile = (file, i) ->
	executeOnSignedUrl file, i, (signedURL) ->
		uploadToS3 file, i, signedURL

 
###
	Use a CORS call to upload the given file to S3. Assumes the url
	parameter has been signed and is accessable for upload.
###
uploadToS3 = (file, i, url) ->
	xhr = createCORSRequest 'PUT', url
	if !xhr
		setProgress 0, 'CORS not supported'

	else
		xhr.onload = ->
			if xhr.status == 200
				++done
				setProgress 0, 'Upload completed.'
				toDB i

			else
				setProgress 0, "Upload error: #{xhr.status}"

 
		xhr.onerror = ->
			setProgress 0, 'XHR error.'
 
		xhr.upload.onprogress = (e) ->
			if e.lengthComputable
				percentLoaded = Math.round((e.loaded / e.total) * 100)
				setProgress percentLoaded, percentLoaded == 100 ? 'Finalizing.' : 'Uploading.'

		xhr.setRequestHeader 'Content-Type', file.type
		xhr.setRequestHeader 'x-amz-acl', 'public-read'
 
		xhr.send file

setProgress = (percent, statusLabel) ->
	progress = document.querySelector '.percent'
	totalPer = Math.round((percent/100+done)/(total-killed)*100) || 0
	progress.style.width = "#{totalPer}%"
	progress.textContent = "#{totalPer}%"
	document.getElementById('progress_bar').className = 'loading'

toDB = (i) ->
	xhr = new XMLHttpRequest()
	xhr.open 'GET', "confirmed/#{i}", true
 
	#Hack to pass bytes through unprocessed.
	xhr.overrideMimeType 'text/plain; charset=x-user-defined'
 
	xhr.onreadystatechange = (e) ->
		if @readyState == 4 && @status == 200
			if @responseText == 'success'
				console.log "Saving file #{i} to database succeeded"
			
			else
				console.log "Saving file #{i} to database failed. Server message: #{@responseText}"

		else if @readyState == 4 && @status != 200
			console.log "Saving file #{i} to database failed. Not 200."
 
	xhr.send()