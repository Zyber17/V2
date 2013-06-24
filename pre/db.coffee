mongoose =  require 'mongoose'
monguurl =  require 'monguurl'
Schema   =  mongoose.Schema
ObjectId =  Schema.ObjectId
        
mongoose.connect 'localhost','torch'

users = new Schema({
	_id:
		type: ObjectId

	username:
		type: String
		unique: true

	slugName:
		type: String
		index:
			unique: true

	email:
		type: String
		unique: true

	bio:
		type: String

	password:
		type: String

	status:
		type: Number
		default: 0
})

articles = new Schema({
	_id:
		type: ObjectId

	title:
		type: String

	slug:
		type: String
		index:
			unique: true

	bodyType:
		type: Number
		default: 0

	body:
		type: String

	html:
		type: String

	section:
		type: ObjectId
		ref: 'sections'

	publishDate:
		type: Date
		default: null

	issue:
		type: ObjectId
		ref: 'issues'

	comments:
		# ???????
})

sections = new Schema({
	_id:
		type: ObjectId

	name:
		type: String
		unique: true

	plannerFormat:
		type: String

})

issues = new Schema({
	_id:
		type: ObjectId

	name:
		type: String
		unique: true

	releaseDate:
		type: Date

})

planners = new Schema({
	_id:
		type: ObjectId

	section:
		type: ObjectId
		ref: 'sections'

	issue:
		type: ObjectId
		ref: 'issues'

	user:
		type: ObjectId
		ref: 'users'

	date:
		type: Date

	body:
		editable:
			type: String

	comments:
		# ???????
})





















