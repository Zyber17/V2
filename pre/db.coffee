mongoose =  require 'mongoose'
monguurl =  require 'monguurl'
Schema   =  mongoose.Schema
ObjectId =  Schema.ObjectId
        
mongoose.connect 'localhost','torch'

users = new Schema {
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
}

articles = new Schema {
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

	issue:
		type: ObjectId
		ref: 'issues'

	publishDate:
		type: Date
		default: null
}

photos = new Schema {
	_id:
		type: ObjectId

	parentID:
		type: ObjectId
		ref: 'articles'
}

sections = new Schema {
	_id:
		type: ObjectId

	name:
		type: String
		unique: true

	plannerFormat:
		type: String

}

issues = new Schema {
	_id:
		type: ObjectId

	name:
		type: String
		unique: true

	releaseDate:
		type: Date

}

planners = new Schema {
	_id:
		type: ObjectId

	section:
		type: ObjectId
		ref: 'sections'

	issue:
		type: ObjectId
		ref: 'issues'

	author:
		type: ObjectId
		ref: 'users'

	date:
		type: Date

	body:
		editable:
			type: String
		rendered:
			type: String
}

comments = new Schema {
	_id:
		type: ObjectId

	body:
		type: String

	author:
		type: ObjectId
		ref: 'users'

	kind:
		type: Number # 0 for article, 1 for planner

	parentID:
		type: ObjectId
}



















