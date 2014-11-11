Discontinued, use [Snapshot](https://github.com/KrauseFx/snapshot) instead.
==============

Helps you create screenshots in multiple languages on different device types using UIAutomation.


Usage
=====


	ruby screenshot.rb app_name script_path [export_to] [json_config_path]
		
- `app_name` The exact name of the app that is shown in the Application Support folder
- `script_path` the path to the Javascript UIAutomation script
- `export_to` [optional] The path all the images will be exported to
- `json_config_path` [optional] a path to a customized json file as configuration (copy the `default.json` and pass the name here)"


You can also store that call in an `*.rb`-File as shown below. ()

	require_relative 'screenshot.rb'

	Screenshooter.instance.run(
		"MyApp", 	# App name
		"test.js", 	# Automation script
		"/Users/#{ENV['USER']}/Desktop/rScreenshooterResults", 	# Output path
		{ 
		"devices" => [
			"iPhone Retina (3.5-inch) - Simulator - iOS 7.1",
			"iPhone Retina (4-inch) - Simulator - iOS 7.1",
			],
			"languages" => ["cs", "da", "de", "fr", "hu", "nb", "nl", "pl", "pt", "ro", "ru", "sk", "sv", "en" ], 
			"ios_version" => "7.1"
			})



### How to determine installed simulators
Get a list of all installed simulator variations with `instruments -w help`
These are the values you can use for the `devices` argument.
