mongoose =  require 'mongoose'
monguurl =  require 'monguurl'
Schema   =  mongoose.Schema
ObjectId =  Schema.ObjectId
        
mongoose.connect 'localhost','torch'

users = new Schema
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
		default: null

	password:
		type: String

	isStaff:
		type: Boolean
		default: false

#Begin articles

articles = new Schema
	title:
		type: String
		required: true

	slug:
		type: String
		index:
			unique: true

	author:
		type: String
		required: true


	lockHTML:
		type: Boolean
		default: false

	body: [articleBodies]

	# section:
	# 	type: ObjectId
	# 	ref: 'sections'

	# issue:
	# 	type: ObjectId
	# 	ref: 'issues'

	publishDate:
		type: Date
		default: null

	createdDate:
		type: Date
		default: Date.now

	status:
		type: Number
		default: 0 # 0: Still Needs Writing, 1: Ready for Section Edit, 2: Ready for Copy Edit, 3: Ready for Approval, 4: Good to Go, 5: On Hold

	approvedBy:
		advisor:
			type: Number
			default: 0 #0: Awaiting approval (neither approved nor rejected), 1: Appoved, 2: Rejected
		administration:
			type: Number
			default: 0 #0: Awaiting approval (neither approved nor rejected), 1: Appoved, 2: Rejected

	staffComments: [
		body:
			rendered:
				type: String
				required: true
			notRendered:
				type: String
				required: true
		
		author: #fix later
			type: String
			required: true
			# 	type: ObjectId
			# 	ref: 'issues'

		edited:
			type: Boolean
			default: false

		createdDate:
			type: Date
			default: Date.now
	]

	views:
		type: Number
		default: 0

	publication:
		type: Number
		default: 0 #0: Torch, 1: Match, 2: Web


articleBodies = new Schema
	body:
		type: String
		required: true
	editor:
		type: String
		required: true
		# 	type: ObjectId
		# 	ref: 'issues'
	editDate:
		type: Date
		default: Date.now


articles.plugin monguurl
    source: 'title'
    target: 'slug'

#End Articles

photos = new Schema
	_id:
		type: ObjectId

	parentID:
		type: ObjectId
		ref: 'articles'


sections = new Schema
	_id:
		type: ObjectId

	name:
		type: String
		unique: true

	plannerFormat:
		type: String


issues = new Schema
	_id:
		type: ObjectId

	name:
		type: String
		unique: true

	releaseDate:
		type: Date


planners = new Schema
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


module.exports =
	ObjectId:
		ObjectId
	Articles:
		mongoose.model 'articles', articles