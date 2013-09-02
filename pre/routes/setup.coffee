db = require('../db')


module.exports = (callback) ->
	dummy=
		name:
			"Webmaster Smith"
		username:
			"webby"
		password:
			"Change me. Ha."

	db.Users.findOne(
		{username:dummy.username},
		(err,resp) ->
			if err
				callback err
			else if resp
				callback "You have already completed the setup. You do not need to run this again."
			else
				firstUser = new db.Users(
					username:
						dummy.username
					name:
						dummy.name
					bio:
						rendered:
							null
						notRendered:
							null
					email:
						dummy.email || "#{dummy.name.toLowerCase().replace(' ','.')}@pineviewtorch.com"
					isStaff:
						true
					password:
						dummy.password
					permissions:
						knowsHTML:
							true
						canPublishStories:
							true
						canDeletePhotos:
							true
						canManageIssues:
							true
						canManageUsers:
							true
						canManageSections:
							true
						canEditPlannerFormats:
							true
						canAcceptPlanners:
							true
						canEditOthersComments:
							true
						canComment:
							true
						canChat:
							true
						accountStatus:
							isWebmaster:
								true
							isRetired:
								false
							isDisabled:
								false
				).save (err)->
					if err
						callback err
					else
						callback "The setup was completed successfully. You may now run the production server."
	)