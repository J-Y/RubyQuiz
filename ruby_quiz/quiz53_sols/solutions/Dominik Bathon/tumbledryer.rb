class TumbleDRYer

  # min_len is the minimum length of replacement chunks (>= 2)
  # min_freq determines how often a chunk has to appear to be replaced
  # escape_char may not be alphanumeric and not "\0", "\\", "\n", ...
  def initialize(min_len = 8, min_freq = 3, escape_char = "#")
    @min_len = [min_len.to_i, 2].max
    @min_freq = min_freq.to_i
    @escape_char = escape_char.to_s[0, 1]
    @escape_char = "#" if @escape_char =~ /\w|\\|\0|\n/
  end

  # returns all substrings of line, that might be replacement candidates
  # if candidates appear multiple times, they are returned multiple times
  def get_chunks(line)
    # split the line
    parts = line.strip.scan /\w+|\W/
    # build all combinations
    (1..(parts.size)).collect do |len|
      (0..(parts.size - len)).collect do |idx|
        parts[idx, len].join ""
      end
    end.flatten.reject do |el|
      el.length < @min_len || # to short
      # reject (nonalpha separated by) whitespace at beginning and end
      (el =~ /(^\W?\s)|(\s\W?$)/)
    end
  end

  # get all replacement candidates (long enough chunks, that appear often
  # enough) for text
  def get_dry_candidates(text)
    freq = Hash.new { |h, k| h[k] = 0 }
    text.each do |line|
      get_chunks(line).each do |chunk|
        freq[chunk] += 1
      end
    end
    freq.keys.reject { |chunk| freq[chunk] < @min_freq }
  end

  # generates a short alphanumeric name for str
  def short_name(str)
    res = str.scan(/\w+/).map { |w| w[0,1] }.join("")
    res.empty? ? "a" : res
  end

  # returns a ruby program that prints text
  # the representation of text in that program will be dried
  # text may not contain "\0"
  def dry(text)
    text = text.dup
    repl = get_dry_candidates(text).sort_by { |c| -c.size }
    snames, used_repl = {}, {}
    # do replacements
    repl.each do |r|
      if text.scan(r).size >= @min_freq # then use it
        sn = short_name(r)
        sn.succ! while snames.has_key? sn
        # extra escape the short names, to avoid resubstitution by a
        # shorter replacement ;-)
        snames[sn] = sn.split(//).join("\0")
        text.gsub!(r, "\0\0#{snames[sn]}\0\0")
        used_repl[sn] = r
      end
    end
    # escape the escape char
    text.gsub!(@escape_char, @escape_char * 2)
    # undo the extra short name escaping
    snames.each do |sn, sn_esc|
      text.gsub!("\0\0#{sn_esc}\0\0", @escape_char + sn + @escape_char)
    end
    # build result
    res = ["r = {"]
    used_repl.each do |s, r|
      res << "  #{s.inspect} => #{r.inspect},"
    end
    res << "}" << ""
    # the "unDRYer"
    esc = "\\#{@escape_char}"
    res << "puts <<'EOT'.gsub(/#{esc}(\\w*)#{esc}/)" +
      %Q!{$1==""?"#{@escape_char}":(r[$1]||! +
      %Q!"#{@escape_char}\#$1#{@escape_char}")}.chop!
    res << text << "EOT"
    res.join "\n"
  end
end

if $0 == __FILE__
  args = []
  if ARGV.first =~ /^(\d+)-(\d+)-(\W)$/
    args = [$1.to_i, $2.to_i, $3]
    ARGV.shift
  end
  puts TumbleDRYer.new(*args).dry(ARGF.read)
end
