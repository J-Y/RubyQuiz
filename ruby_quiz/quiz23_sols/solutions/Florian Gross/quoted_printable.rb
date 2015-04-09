module QuotedPrintable
  extend self

  # Encodes text as quoted printable. The second argument specifies characters that
  # should be encoded in addition to the ones that are automatically quoted ones.
  # It is a string that specifies characters and character ranges as taken by
  # String#delete and so on.
  def encode(text, also_encode = "")
    text.gsub(/[\t ](?:[\v\t ]|$)|[=\x00-\x08\x0B-\x1F\x7F-\xFF#{also_encode}]/) do |char|
      char[0 ... -1] + "=%02X" % char[-1]
    end.gsub(/^(.{75})(.{2,})$/) do |match|
      base, continuation = $1, $2
      continuation = base.slice!(/=(.{0,2})\Z/).to_s + continuation
      base + "=\n" + continuation
    end.gsub("\n", "\r\n")
  end

  # Decodes quoted printable text. The second argument specifies whether =af should
  # be accepted as well as =AF.
  def decode(text, allow_lowercase = false)
    encoded_re = Regexp.new("=([0-9A-F]{2})", allow_lowercase ? "i" : "")
    text.gsub("\r\n", "\n").gsub("=\n", "").gsub(encoded_re) do
      $1.to_i(16).chr
    end
  end
end

if __FILE__ == $0 then
  require 'optparse'

  options = {
    :mode => :encode,
    :also_encode => ""
  }

  ARGV.options do |opts|
    script_name = File.basename($0)
    opts.banner = "Usage: ruby #{script_name} [options]"

    opts.separator ""
    opts.separator "Specific options:"

    opts.on("-d", "--decode", "Decode quoted printable to plain text.") do
      options[:mode] = :decode
    end

    opts.on("-e", "--encode", "Encode plain text to quoted printable. (Default)") do
      options[:mode] = :encode
    end

    opts.on("-x", "--encode-xml", "Also encode XML meta characters.") do
      options[:also_encode] << "<>&"
    end

    opts.on("-a", "--also-encode=chars", String,
      "Also encode the specified characters or character ranges."
    ) do |arg|
      options[:also_encode] << arg
    end

    opts.separator ""
    opts.separator "Common options:"

    opts.on("-h", "--help", "Show this help message.") do
      puts opts
      exit
    end

    opts.parse!
  end

  ARGF.binmode if options[:mode] == :decode
  text = ARGF.read

  result = case options[:mode]
    when :encode then
      QuotedPrintable.encode(text, options[:also_encode])
    when :decode then
      QuotedPrintable.decode(text)
  end

  STDOUT.binmode if options[:mode] == :encode
  STDOUT.puts result
end
