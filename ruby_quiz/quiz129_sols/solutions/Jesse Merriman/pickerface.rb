require 'names_db'
require 'name_image'

# Pickerface handles the interface for pick.rb.
class Pickerface
  def initialize filename
    @db_file = filename
    self
  end

  # Read names from standard input and add the to the DB.
  def add_names
    puts 'Enter names to add, one per line. Blank or ^D to stop.'
    db = NamesDB.new @db_file, true
    while name = $stdin.gets and name != "\n"
      begin
        db.add_name name.chomp
      rescue NamesDB::AlreadyAdded => ex
        $stderr.puts ex
      end
    end
  end

  # List all names to standard output.
  def list_names
    existing_db do |db|
      puts str = "Contents of #{@db_file}:"
      puts '-' * str.length
      db.each_name { |name| puts name }
    end
  end

  # Clear the DB of all names.
  def clear
    existing_db do |db|
      db.clear
      puts "#{@db_file} has been cleared of all names."
    end
  end

  # Randomly choose a name, write it to standard output, and delete it from the
  # DB.
  def pick_simple
    pick { |name| puts name }
  end

  # Randomly choose a name, display it in a fancy way, and delete it from the
  # DB.
  def pick_fancy
    pick { |name| NameImage.fancy(name).animate }
  end

  # Like pick_fancy, but save the image to the given filename instead of
  # displaying it.
  def save_fancy filename
    pick { |name| NameImage.fancy(name).write(filename) }
  end

  # Destroy the DB.
  def destroy
    existing_db do |db|
      db.destroy
      puts "#{@db_file} has been destroyed."
    end
  end

  private

  # Yield a NamesDB if @db_file exists, otherwise print an error.
  def existing_db
    begin
      yield NamesDB.new(@db_file)
    rescue NamesDB::NonexistantDB
      $stderr.puts "Error: #{@db_file} does not exist!"
    end
  end

  # Yield a randomly-picked name, or a message that there are none left.
  def pick
    existing_db do |db|
      if name = db.pick
        db.delete_name name
        yield name
      else
        yield 'No one left!'
      end
    end
  end
end
