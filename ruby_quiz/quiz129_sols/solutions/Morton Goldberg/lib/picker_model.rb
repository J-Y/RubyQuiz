#  picker_model.rb
#  Quiz 129
#  
#  Created by Morton Goldberg on June 25, 2007.
#  Modified July 01, 2007
#  The data model for the Name Picker application

require "yaml"

class PickerModel
   NO_MORE = "Everybody has won a prize!\n--"
   DATA_FILES = [
      "attendees.txt",
      "eligibles.yaml",
      "winners.yaml",
   ]
   DATA_PATHS = {}
   DATA_FILES.each do |name|
      key = File.basename(name, ".*").to_sym
      val = File.join(ROOT_DIR, "data", name)
      DATA_PATHS[key] = val
   end

   # Class method
   # /data is OK when it contains
   #     <attendees.txt>
   #     <attendees.txt, eligibles.yaml, winners.yaml>
   def self.data_check
      data_dir = File.join(ROOT_DIR, "data")
      files =  Dir.entries(data_dir).reject { |f| f[0] == ?. }
      case files.size
      when 3
         :eligibles if files == DATA_FILES 
      when 1
         :attendees if files[0] == DATA_FILES[0]
      else false
      end
   end

   # Instance methods
   def initialize
      data_source = PickerModel.data_check
      case data_source
      when :attendees
         @eligibles = File.read(DATA_PATHS[:attendees]).split("\n\n")
      when :eligibles
         @eligibles = YAML.load_file(DATA_PATHS[:eligibles])
      else
         puts "Directory #{File.join(ROOT_DIR, "data") } is corrupt"
         abort
      end
      if File.exist?(DATA_PATHS[:winners])
         @winners = YAML.load_file(DATA_PATHS[:winners])
      else
         @winners = []
      end
   end
   # Permit view to determine if prizes are all gone.
   def no_more?
      return false unless @eligibles.empty?
      NO_MORE
   end
   # Pick a winner, update eligibles.yaml and winners.yaml, and report
   # winner.
   def winner
      n = rand(@eligibles.size)
      result = @eligibles[n]
      @eligibles.delete_at(n)
      File.open(DATA_PATHS[:eligibles], "w") do |file|
         YAML.dump(@eligibles, file)
      end
      @winners << result
      File.open(DATA_PATHS[:winners], "w") do |file|
         YAML.dump(@winners, file)
      end
      result
   end
end
