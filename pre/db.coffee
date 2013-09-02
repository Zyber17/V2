mongoose =  require 'mongoose'
monguurl =  require 'monguurl'
bcrypt  =  require 'bcrypt'
Schema   =  mongoose.Schema
ObjectId =  Schema.ObjectId
saltWorkFactor = 10
        
mongoose.connect 'localhost','torch'
database = mongoose.connection

database.on 'error', console.error.bind(console, 'connection error:')

users = new Schema
	name:
		type: String
		required: true
		index:
			unique: true

	username:
		type: String
		required: true
		unique: true

	isStaff:
		type: Boolean
		default: true
		required: true

	email:
		type: String
		unique: true

	bio:
		rendered:
			type: String

		notRendered:
			type: String

	password:
		type: String
		required: true

	slug:
		type: String

	permissions:
		knowsHTML:
			type: Boolean
			default: false

		canPublishStories:
			type: Boolean
			default: true

		canDeletePhotos:
			type: Boolean
			default: true

		canManageIssues:
			type: Boolean
			default: false

		canManageUsers:
			type: Boolean
			default: false

		canManageSections:
			type: Boolean
			default: false

		canEditPlannerFormats:
			type: Boolean
			default: false

		canAcceptPlanners:
			type: Boolean
			default: false

		canComment:
			type: Boolean
			default: true

		canEditOthersComments:
			type: Boolean
			default: true

		canChat:
			type: Boolean
			default: true

		accountStatus:
			isWebmaster:
				type: Boolean
				default: false

			isRetired:
				type: Boolean
				default: false

			isDisabled:
				type: Boolean
				default: false


users.plugin monguurl
    source: 'name'
    target: 'slug'


#/via http://devsmash.com/blog/password-authentication-with-mongoose-and-bcrypt
users.pre 'save', (next) ->
    user = @

    # only hash the password if it has been modified (or is new)
    if !user.isModified('password')
    	next()

    # generate a salt
    bcrypt.genSalt saltWorkFactor, (err, salt) ->
        if err
        	next err

        # hash the password using our new salt
        bcrypt.hash user.password, salt, (err, hash) ->
            if err
            	next err

            # override the cleartext password with the hashed one
            user.password = hash
            next()


users.methods.comparePassword = (candidatePassword, callback) ->
    bcrypt.compare candidatePassword, @.password, (err, isMatch) ->
        if err
        	callback err

        callback null, isMatch



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

	photos: [photos]

	section:
		type: ObjectId
		ref: 'sections'

	issue:
		type: ObjectId
		ref: 'issues'

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
		
		author:
			type: String #ObjectId
			# ref: 'users'

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
		type: ObjectId
		ref: 'users'

	editDate:
		type: Date
		default: Date.now


articles.plugin monguurl
    source: 'title'
    target: 'slug'

#End Articles

photos = new Schema
	number:
		type: Number
		index:
			unique: true

	isRotator:
		type: Boolean
		default: false

	isPreview:
		type: Boolean
		default: false

	uploadDate:
		type: Date
		required: true

	photographer:
		type: Date
		default: Date.now
		required: true

	caption:
		type: String
		required: true

	slug:
		type: String
		index:
			unique: true


photos.plugin monguurl
    source: 'number'
    target: 'slug'


issues = new Schema
	title:
		type: String
		required: true

	slug:
		type: String
		index:
			unique: true

	publication:
		type: Number
		default: 0 #0: Torch, 1: Match
		required: true

	publishDate:
		type: Date
		required: true

	createdDate:
		type: Date
		default: Date.now
		required: true

	download:
		trpe: String


issues.plugin monguurl
    source: 'title'
    target: 'slug'


sections = new Schema
	title:
		type: String
		required: true

	slug:
		type: String
		index:
			unique: true


sections.plugin monguurl
    source: 'title'
    target: 'slug'


# planners = new Schema
# 	_id:
# 		type: ObjectId

# 	section:
# 		type: ObjectId
# 		ref: 'sections'

# 	issue:
# 		type: ObjectId
# 		ref: 'issues'

# 	author:
# 		type: ObjectId
# 		ref: 'users'

# 	date:
# 		type: Date

# 	body:
# 		editable:
# 			type: String
# 		rendered:
#			type: String


module.exports =
	ObjectId:
		ObjectId
	Articles:
		mongoose.model 'articles', articles
	Issues:
		mongoose.model 'issues', issues
	Sections:
		mongoose.model 'sections', sections
	Users:
		mongoose.model 'users', users