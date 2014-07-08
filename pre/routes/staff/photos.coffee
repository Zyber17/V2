db = require '../../db'
crypto = require 'crypto'
moment = require 'moment'

exports.view = (req,res,next) ->
	res.render 'staff/uploadPhoto'

exports.auth = (req,res,next) ->
	createS3Policy req.params.slug, req.params.mime, req.params.filename, (err, policy, name) ->
		if !err
			ret =
				policy:
					policy
				name:
					name

			res.end JSON.stringify ret
		else
			console.log "Error (photos): #{err}"
			res.send 403, err
	

createS3Policy = (slug, mime, name, callback) ->
	db.Articles.findOne(
		slug:
			slug
	).exec((err, resp) ->
		go = true
		extention = ''
		switch mime.toLowerCase()
			when 'image/png'
				extension = 'png'
			when 'image/jpg'
				extension = 'jpg'
			when 'image/jpeg'
				extension = 'jpeg'
			when 'image/gif'
				extension = 'gif'
			else
				go = false
		if go
			S3_BUCKET_NAME = 'torch_photos'
			S3_ACCESS_KEY  = '***REMOVED***'
			S3_SECRET_KEY  = '***REMOVED***'

			if process.env.NODE_ENV == 'dev'
				S3_BUCKET_NAME = 'torch_test'

			name = crypto.createHmac("sha1", S3_SECRET_KEY).update("#{name}: #{mime} at #{new Date().getTime()} random is #{Math.floor(Math.random()*99999999).toString()}").digest("base64").replace('=','_').replace('/','__')

			expires = moment().add('minutes', 15).unix()

			amzHeaders = "x-amz-acl:public-read"	

			stringToSign = "PUT\n\n#{mime}\n#{expires}\n#{amzHeaders}\n/#{S3_BUCKET_NAME}/#{resp._id}/#{name}.#{extension}"

			sig = crypto.createHmac("sha1", S3_SECRET_KEY).update(stringToSign).digest("base64")

			signed_request = "https://s3.amazonaws.com/#{S3_BUCKET_NAME}/#{resp._id}/#{name}.#{extension}?AWSAccessKeyId=#{S3_ACCESS_KEY}&Expires=#{expires}&Signature=#{encodeURIComponent sig}"

			# ret = JSON.stringify
			# 	signed_request: 
			# 	url: encodeURIComponent(url)
				

			callback null, signed_request, "#{name}.#{extension}"
		else
			callback 'Invalid mime', null, null
	)
	


exports.addToDB = (req,res,next) ->
	db.Articles.findOne(
		slug:
			req.params.slug
	).exec((err, resp) ->
		if !err
			if resp
				resp.photos.unshift
					name:
						req.params.name
					date:
						moment().toDate()
					photographer:
						req.session.user.name # Update this later
				resp.save (err, resp)->
					if !err
						res.end 'success'
					else
						console.log "Error (photos): #{err}"
						res.send 403, err
			else
				res.render 'errors/404', {err: "Article not found"}
		else
			console.log "Error (photos): #{err}"
			res.send 403, err
	)