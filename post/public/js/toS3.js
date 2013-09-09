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

  var files = document.getElementById('files').files; 

  var output = [];
  for (var i = 0, f; f = files[i]; i++) 
  {
    uploadFile(f);
  }
  total = i
}

/**
 * Execute the given callback with the signed response.
 */
function executeOnSignedUrl(file, callback)
{
  var xhr = new XMLHttpRequest();
  xhr.open('GET', 'signS3/'+file.type+'/'+file.name);

  // Hack to pass bytes through unprocessed.
  xhr.overrideMimeType('text/plain; charset=x-user-defined');

  xhr.onreadystatechange = function(e) 
  {
    if (this.readyState == 4 && this.status == 200) 
    {
      var a = JSON.parse(this.responseText)
      callback(a.policy, a['name']);
    }
    else if(this.readyState == 4 && this.status != 200)
    {
      ++killed;
      if(this.status == 403){
        if(this.responseText = "Invalid mime") {
          alert(file.name+" is not an accepted file type.")
        }
      }else {
        setProgress(0, 'Could not contact signing script. Status = ' + this.status);
      }
    }
  };

  xhr.send();
}

function uploadFile(file)
{
  executeOnSignedUrl(file, function(signedURL, name) 
  {
    uploadToS3(file, signedURL, name);
  });
}

/**
 * Use a CORS call to upload the given file to S3. Assumes the url
 * parameter has been signed and is accessible for upload.
 */
function uploadToS3(file, url, name)
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
        setProgress(0, 'Upload completed.'); //0 not 100 Becuase the full percentage is already count in `done`
        toDB(name);
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
        var percentLoaded = Math.round((e.loaded / e.total));
        setProgress(percentLoaded);
      }
    };

    xhr.setRequestHeader('Content-Type', file.type);
    xhr.setRequestHeader('x-amz-acl', 'public-read');

    xhr.send(file);
  }
}

function setProgress(percent)
{
  var progress = document.querySelector('.percent');
  var totalPer = (percent+done)/(total-killed)*100 || 0;
  progress.style.width = totalPer + '%';
  progress.textContent = totalPer + '%';
  document.getElementById('progress_bar').className = 'loading';
}

function toDB(name) {
  var xhr = new XMLHttpRequest();
  xhr.open('GET', 'confirmed/'+name);

  // Hack to pass bytes through unprocessed.
  xhr.overrideMimeType('text/plain; charset=x-user-defined');

  xhr.onreadystatechange = function(e) 
  {
    if (this.readyState == 4 && this.status == 200) 
    {
      console.log('Success uploading '+name);
    }
    else if(this.readyState == 4 && this.status != 200)
    {
      console.log("Error, line 151");
    }
  };

  xhr.send();
}