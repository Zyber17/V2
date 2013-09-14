db = require '../db'


module.exports = (callback) ->
	dummy=
		name:
			"Webmaster Smith"
		username:
			"webby"
		password:
			"***REMOVED***"

	db.Users.findOne(
		{username:dummy.username},
		(err,resp) ->
			if err
				callback err
			else if resp
				callback "You have already completed the setup. You do not need to run this again."
			else
				new db.Users(
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
						sectionErrs = 0
						sectionList = ["News","Entertainment","Science and Technology","Humor","Features","Opinion","Sports","Focus"]
						for sections in sectionList
							new db.Sections(
								title: sections
							).save (err)->
								if err
									sectionErrs++
									callback err

						if sectionErrs > 0
							callback "The setup was completed successfully. You may now run the production server."
						else
							callback err
	)