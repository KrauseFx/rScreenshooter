require 'singleton'
require 'JSON'
require 'FileUtils'


class Screenshooter
	include Singleton

	def run(app_name, script_path, export_path, config = {})
		raise "The first parameter app_name is mandatory!" unless app_name
		raise "The second parameter script_path is mandatory!" unless script_path

		path = config["output_path"] || "./Results"
		@results_path = Time.now.strftime "#{export_path}/%Y-%m-%d %H:%M:%S"
		puts "Exporting all the screenshots into '#{@results_path}'"

		clean_up
		prepare_folders

		@automation_script = script_path
		raise "UIAutomation script not found at path '#{@automation_script}'" unless File.exists?(@automation_script)
		@devices = config["devices"]
		@languages = config["languages"]
		@ios_version = config["ios_version"]
		@app_name = app_name


		@applications_folder = config[:applications_folder] || 
										"/Users/#{ENV['USER']}/Library/Application Support/iPhone Simulator/#{@ios_version}/Applications/"

		@app_path = get_app_path



		@languages.each do |language|
			system("./bin/switch_language #{language}")

			@devices.each do |device|
				puts "Running #{device} in language #{language}"
				system("./bin/switch_simulator \"#{device}\" #{@ios_version}")
				sleep 2
				system("./bin/switch_simulator \"#{device}\" #{@ios_version}") # TOOD: for some reason this is required twice
				sleep 2

				execute

				system("mv Results/Run*/*.png '#{@results_path}'")
			end
		end



		clean_up

		system("open '#{@results_path}'")
	end

	def clean_up
		Dir.glob("*").each { |file_name| FileUtils.rm_rf(file_name) if file_name.include?"instrumentscli"}
	end

	def prepare_folders
		FileUtils.mkdir_p "Results"
		FileUtils.mkdir_p @results_path
		system("rm 'Latest'")
		system("ln -s '#{@results_path}' Latest")
	end

	def get_app_path
		Dir.glob("#{@applications_folder}*").each do |f| 
			Dir.glob("#{f}/*").each do |app|
				if app.include?"#{@app_name}.app"
					puts "Found the app '#{app}'"
					return app
				end
			end
		end
		raise "Sorry, I couldn't find an app with the name '#{@app_name}'"
	end

	def execute
		# xcode-select -p
		command = "instruments -t /Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate"
		command += " \"#{@app_path}\" -e UIASCRIPT \"#{@automation_script}\" -e UIARESULTSPATH Results/"
		puts command
		system(command)
	end

end

if __FILE__ == $0
	if !ARGV[0] or !ARGV[1]
		raise "Usage: ruby screenshot.rb app_name script_path [export_to] [json_config_path]\n
			app_name: The exact name of the app that is shown in the Application Support folder
			script_path: the path to the Javascript UIAutomation script
			export_to: [optional] The path all the images will be exported to
			json_config_path: [optional] a path to a customized json file as configuration (copy the default.json and pass the name here)\n\n"
	end
	
	config = JSON.parse(File.read(ARGV[3] ? ARGV[3] : "config/default.json"))
  	Screenshooter.instance.run(ARGV[0], ARGV[1], ARGV[2], config)
end
