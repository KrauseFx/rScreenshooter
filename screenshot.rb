require 'singleton'
require 'JSON'
require 'FileUtils'


class Screenshooter
	include Singleton

	def run(app_name, script_path, config = {})
		raise "The first parameter app_name is mandatory!" unless app_name
		raise "The second parameter script_path is mandatory!" unless script_path

		@results_path = Time.now.strftime "Results/%Y-%m-%d %H:%M:%S"

		clean_up
		prepare_folders

		@automation_script = config[:automation_script] || "test.js"
		@devices = config[:devices] || JSON.parse(File.read("config/devices.json"))
		@languages = config[:languages] || JSON.parse(File.read("config/languages.json"))
		@ios_verison = config[:ios_verison] || "7.0.3"
		@app_name = app_name


		@applications_folder = config[:applications_folder] || 
										"/Users/#{ENV['USER']}/Library/Application Support/iPhone Simulator/#{@ios_verison}/Applications/"

		@app_path = get_app_path



		@languages.each do |language|
			system("./bin/switch_language #{language}")

			@devices.each do |device|
				puts "Running #{device} in language #{language}"
				system("./bin/switch_simulator \"#{device}\" 7.0")
				sleep 2
				system("./bin/switch_simulator \"#{device}\" 7.0") # TOOD: for some reason this is required twice
				sleep 2

				execute

				system("mv Results/Run*/*.png '#{@results_path}'")
			end
		end

		clean_up

		system("rm 'Latest'")
		system("ln -s '#{@results_path}' Latest")
		system("open '#{@results_path}'")
	end

	def clean_up
		Dir.glob("*").each { |file_name| FileUtils.rm_rf(file_name) if file_name.include?"instrumentscli"}
	end

	def prepare_folders
		FileUtils.mkdir_p "Results"
		FileUtils.mkdir_p @results_path
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
	raise "Pass the exact name of the app as the first parameter" unless ARGV[0]
	raise "Pass the path of the UIAutomation script as the second parameter" unless ARGV[1]
  Screenshooter.instance.run(ARGV[0], ARGV[1])
end
