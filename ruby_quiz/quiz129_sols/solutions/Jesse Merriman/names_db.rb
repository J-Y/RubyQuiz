require 'sqlite'

# NamesDB wraps up a SQLite::Database.
class NamesDB
  class AlreadyAdded  < StandardError; end
  class NonexistantDB < StandardError; end

  NamesTable = 'names'

  # Initialize a new NamesDB.
  # - filename: The filename of the DB.
  # - create: If true, and the DB doesn't exist, it'll be created. If false,
  #   and the DB doesn't exist, raise a NonexistantDB exception.
  # - optimize: Enable optimizations.
  def initialize filename, create = false, optimize = true
    raise NonexistantDB if not create and not File.exists? filename

    @filename = filename
    @db = SQLite::Database.new filename
    create_names_table if @db.table_info(NamesTable).empty?
    enable_optimizations if optimize
    prepare_statements
    self
  end

  # Add a name to the DB.
  def add_name name
    begin
      @statements[:add_name].execute! NamesTable, name
    rescue SQLite::Exceptions::SQLException
      raise AlreadyAdded.new, "#{name} is already in the DB!"
    end
  end

  # Delete a name from the DB.
  def delete_name name
    @statements[:delete_name].execute! NamesTable, name
  end

  # Yield each name in the DB.
  def each_name
    @statements[:each_name].execute!(NamesTable) { |res| yield res[0] }
  end

  # Clear the DB of all names.
  def clear
    @statements[:clear].execute! NamesTable
  end

  # Destroy the DB.
  def destroy
    @db.close
    File.delete @filename
  end

  # Return a randomly-chosen name, or nil if there are non left.
  def pick
    res = @statements[:pick].execute! NamesTable
    res.empty? ? nil : res[0][0]
  end

  private

  def create_names_table
    @db.execute <<-SQL, NamesTable
      CREATE TABLE ? (
        name TEXT PRIMARY KEY
      );
    SQL
  end

  def enable_optimizations
    @db.execute 'PRAGMA default_synchronous = OFF;'
  end

  def prepare_statements
    @statements = {}

    @statements[:add_name]    = @db.prepare 'INSERT INTO ? (name) VALUES (?);'
    @statements[:delete_name] = @db.prepare 'DELETE FROM ? WHERE name = ?;'
    @statements[:each_name]   = @db.prepare 'SELECT name FROM ?;'
    @statements[:clear]       = @db.prepare 'DELETE FROM ?; VACUUM;'
    @statements[:pick]        = @db.prepare <<-SQL
      SELECT name FROM ? ORDER BY random() LIMIT 1;
    SQL
  end
end
