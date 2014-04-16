require_relative 'screenshot.rb'

Screenshooter.instance.run(
	"DDI Demo", 	# App name
	"test.js", # Store Shots
	"/Users/#{ENV['USER']}/Desktop/rScreenshooterResults", 	# Output path
	{ 
	"devices" => [
		"iPhone Retina (3.5-inch) - Simulator - iOS 7.1",
		"iPhone Retina (4-inch) - Simulator - iOS 7.1",
		],
		"languages" => [
			"cs", 
			"da", 
			"de",
			"fr", 
			"hu", 
			"nb",
			"nl", 
			"pl", 
			"pt",
			"ro", 
	  	 	"ru",
			"sk",
			"sv",
			"en" #Restore
			], 
		"ios_version" => "7.1"
		})