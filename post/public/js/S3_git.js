//http://www.ioncannon.net/programming/1539/direct-browser-uploading-amazon-s3-cors-fileapi-xhr2-and-signed-puts/
var total, done, killed;
function createCORSRequest(method, url) 
{
	var xhr = new XMLHttpRequest();
	if ("withCredentials" in xhr) 
	{
		xhr.open(method, url, true);
	} 
	else if (typeof XDomainRequest != "undefined") 
	{
		xhr = new XDomainRequest();
		xhr.open(method, url);
	} 
	else
	{
		xhr = null;
	}
	return xhr;
}
 
function handleFileSelect(evt) 
{
	total = 0;
	done = 0;
	killed = 0;
	setProgress(0, 'Upload started.');
 
	var files = document.getElementById("files").files; 
 
	var output = [];
	for (var i = 0, f; f = files[i]; i++) 
	{
		uploadFile(f,i);
	}
	total = i;
}
 
/**
 * Execute the given callback with the signed response.
 */
function executeOnSignedUrl(file, i, callback)
{
	var xhr = new XMLHttpRequest();
	xhr.open('GET', 'signS3/' + file.type + '?noCacheingPlease=' + encodeURIComponent(file.name), true);
 
	// Hack to pass bytes through unprocessed.
	xhr.overrideMimeType('text/plain; charset=x-user-defined');
 
	xhr.onreadystatechange = function(e) 
	{
		if (this.readyState == 4 && this.status == 200) 
		{
			callback(this.responseText);
		}
		else if(this.readyState == 4 && this.status != 200)
		{
			if(this.status == 403){
				++killed;
				if(this.responseText = "Invalid mime") {
					alert(file.name+" is not an image (png, jpg, jpeg, gif).")
				}
			}else {
				setProgress(0, 'Could not contact signing script. Status = ' + this.status);
			}
		}
	};
 
	xhr.send();
}
 
function uploadFile(file, i)
{
	executeOnSignedUrl(file, i, function(signedURL) 
	{
		uploadToS3(file, i, signedURL);
	});
}
 
/**
 * Use a CORS call to upload the given file to S3. Assumes the url
 * parameter has been signed and is accessable for upload.
 */
function uploadToS3(file, i, url)
{
	var xhr = createCORSRequest('PUT', url);
	if (!xhr) 
	{
		setProgress(0, 'CORS not supported');
	}
	else
	{
		xhr.onload = function() 
		{
			if(xhr.status == 200)
			{
				++done;
				setProgress(0, 'Upload completed.');
				toDB(i);
			}
			else
			{
				setProgress(0, 'Upload error: ' + xhr.status);
			}
		};
 
		xhr.onerror = function() 
		{
			setProgress(0, 'XHR error.');
		};
 
		xhr.upload.onprogress = function(e) 
		{
			if (e.lengthComputable) 
			{
				var percentLoaded = Math.round((e.loaded / e.total) * 100);
				setProgress(percentLoaded, percentLoaded == 100 ? 'Finalizing.' : 'Uploading.');
			}
		};
 
		xhr.setRequestHeader('Content-Type', file.type);
		xhr.setRequestHeader('x-amz-acl', 'public-read');
 
		xhr.send(file);
	}
}
function setProgress(percent, statusLabel)
{
	var progress = document.querySelector('.percent');
	var totalPer = (percent/100+done)/(total-killed)*100 || 0;
	progress.style.width = totalPer + '%';
	progress.textContent = totalPer + '%';
	document.getElementById('progress_bar').className = 'loading';
}
function toDB(i)
{
	var xhr = new XMLHttpRequest();
	xhr.open('GET', 'confirmed/'+i, true);
 
	// Hack to pass bytes through unprocessed.
	xhr.overrideMimeType('text/plain; charset=x-user-defined');
 
	xhr.onreadystatechange = function(e) 
	{
		if (this.readyState == 4 && this.status == 200) 
		{
			if(this.responseText == 'success') {
				console.log('Saving file '+i+' to database succeeded');
			}else {
				console.log('Saving file '+i+' to database failed. Server message: '+this.responseText);
			}
		}
		else if(this.readyState == 4 && this.status != 200)
		{
			console.log('Saving file '+i+' to database failed. Not 200.');
		}
	};
 
	xhr.send();
}