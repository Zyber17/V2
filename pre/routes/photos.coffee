crypto = require 'crypto'
moment = require 'moment'
db = require '../db'

exports.view = (req,res,next) ->
	res.render 'uploadPhoto'

exports.auth = (req,res,next) ->
	createS3Policy req.params.slug, req.params.mime, (err,ret) ->
		if !err
			res.end ret
		else
			console.log "Error (photos): #{err}"
			res.send 403, err
	

createS3Policy = (slug, mimetype, callback) ->
	go = true
	extention = ''
	name = Math.floor(Math.random()*110009).toString()
	switch mimetype
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
		S3_BUCKET_NAME = 'V2_test'
		S3_ACCESS_KEY  = 'AKIAJOYLRYNKXNNQPCGQ'
		S3_SECRET_KEY  = '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'

		expires = moment().add('minutes', 10).unix()

		amzHeaders = "x-amz-acl:public-read"	
		stringToSign = "PUT\n\n#{mimetype}\n#{expires}\n#{amzHeaders}\n/#{S3_BUCKET_NAME}/#{slug}/#{name}.#{extension}"
		sig = crypto.createHmac("sha1", S3_SECRET_KEY).update(stringToSign).digest("base64")

		signed_request = "https://s3.amazonaws.com/#{S3_BUCKET_NAME}/#{slug}/#{name}.#{extension}?AWSAccessKeyId=#{S3_ACCESS_KEY}&Expires=#{expires}&Signature=#{encodeURIComponent sig}"

		# ret = JSON.stringify
		# 	signed_request: 
		# 	url: encodeURIComponent(url)
			

		callback null, signed_request
	else
		callback 'Invalid mime', null


exports.addToDB = (req,res,next) ->
	res.end 'success'