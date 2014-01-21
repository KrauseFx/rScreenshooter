require 'singleton'
require 'JSON'
require 'FileUtils'


class Screenshooter
	include Singleton

	def run(config = {})
		clean_up
		prepare_folders

		@automation_script = config[:automation_script] || "test.js"
		@devices = config[:devices] || JSON.parse(File.read("config/devices.json"))
		@languages = config[:languages] || JSON.parse(File.read("config/languages.json"))
		@ios_verison = config[:ios_verison] || "7.0.3"
		@app_name = config[:app_name] || "9"


		@applications_folder = config[:applications_folder] || 
										"/Users/#{ENV['USER'] }/Library/Application Support/iPhone Simulator/#{@ios_verison}/Applications/"

		@app_path = get_app_path

		@languages.each do |language|
			system("./bin/switch_language #{language}")

			@devices.each do |device|
				puts "Running #{device} in langauge #{language}"
				system("./bin/switch_simulator \"#{device}\" 7.0")
				sleep 2
				system("./bin/switch_simulator \"#{device}\" 7.0") # TOOD: for some reason this is required twice
				sleep 2

				execute
			end
		end

		clean_up
	end

	def clean_up
		Dir.glob("*").each { |file_name| FileUtils.rm_rf(file_name) if file_name.include?"instrumentscli"}
	end

	def prepare_folders
		FileUtils.mkdir_p "Results"
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
  Screenshooter.instance.run()
end