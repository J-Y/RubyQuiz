module NamePicker
  class Controller
    require 'lucky_filter'
    require 'view'
    require 'optparse'
    require 'csv'
  
    PICK  = :pick
    PICKS   = 1
    SOURCE  = STDIN

    def initialize args
      OptionParser.new do |opts|
        opts.banner = "Usage: #{ $0 } [OPTIONS]" +
        " (default: --#{ PICK } #{ PICKS } --from #{ SOURCE })"

        opts.separator "Options:"

        opts.on '--from file', String,
        'Read CSV from file (default: STDIN)' do |file|
          begin
            @source = File.open file, 'r'

          rescue Errno::ENOENT
            abort "Source file #{ file } couldn't be read, see --help."

          end
        end
        opts.on '--list [COLLECTION]', [ :all, :lucky, :unlucky ],
        'List (all, lucky or unlucky)' do |list|
          @action, @arg = case list
          when :lucky then [ :list, :lucky ]
          when :unlucky then [ :list, :unlucky ]
          else [ :list, :all ]
          end
        end
        opts.on '--pick N', Integer,
        'Pick N (default: 1) lucky attendees' do |n|
          @action, @arg = :pick, n
        end

        opts.on_tail '--test', 'Run tests' do
          system "#{ RUBY_BIN } -v test_suite.rb" and exit or
          abort "#{ RUBY_BIN } could not be found."

        end
        opts.on_tail '--help', 'Shows this message' do
          abort opts.to_s

        end
      end.parse args

      @filter = LuckyFilter.new CSV::Reader.create( @source || SOURCE, "\t" )
      @view = View.new
    end
  
    def recieved? dataset
      begin
        @view.render dataset

      rescue => error
        warn 'Could not render dataset.' + error.to_s
        return false

      end
    end

    def run
      send( @action || PICK, @arg || PICKS)
    end

    protected
    def pick amount
      begin
        ( 1 .. amount ).each { |index| @filter.pick_for self }

      rescue => error
        puts error.to_s

      end
    end

    def list group
      @view.render @filter.send( group )
    end

  end
end
