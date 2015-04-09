# vim: sw=2 sts=2 nu tw=0 expandtab:
#
require 'fileutils'
require 'torus'

def usage msg = nil
  $stderr.puts msg if msg
  $stderr.puts <<-EOS
  usage:
  #{$0} [options] height width vapor_probability

  options and their defaults
  -s|--start <height>/2@<width>/2      where to put the initial freezer
                                       please use Smalltalk syntax here
  -n|--name   run-<height>-<width>     name of the output file
  -v|--vapor  255/0/255                rgb value for PPM
              O                        use strings for ASCII
  -0|--vacuum 0/0/0                    idem
              <space>
  -i|--ice    255/255/255              idem
              *
  -f|--format ppm                      ppm or ascii are supported
                                       write your own plugins ;)

  have fun
  EOS
  exit -1
end

@start = @name = nil
@vapor = nil
@vacuum = nil
@ice    = nil
@format = "ppm" 
options = { /^-f|^--format/ => :format,
            /^-s|^--start/  => :start,
            /^-n|^--name/   => :name,
            /^-v|^--vapor/  => :vapor,
            /^-0|^--vacuum/ => :vacuum,
            /^-i|^--ice/    => :ice }
loop do
  break if ARGV.empty?
  break if ARGV.first == "--"
  break unless /^-/ === ARGV.first
  illegal_option = true
  options.each do
    | opt_reg, opt_sym |
    if opt_reg === ARGV.first then
      usage "Missing argument for option #{ARGV}" if ARGV.length < 2
      instance_variable_set( "@#{opt_sym}", ARGV[1] )
      ARGV.slice!( 0, 2 )
      illegal_option = false
    end
  end
  usage ARGV.first if illegal_option 
end
usage ARGV.join(", ") unless ARGV.size == 3

require @format rescue usage

begin
  mkdir( "output" ) unless File.directory?( "output" ) 
rescue 
  $stderr.puts 'Cannot create output directory "output"'
  usage
end

t = Torus( *(ARGV << @start) )
t.name = @name || "run-#{ARGV[0..1].join("-")}"
t.formatter = Formatter.new( ICE => @ice, VAPOR => @vapor, VACUUM => @vacuum )
t.start_sim
