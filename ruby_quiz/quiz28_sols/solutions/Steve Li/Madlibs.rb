class Story
  attr_accessor :placeholders

  def initialize(base)
    @placeholders = []

    story_parts = []
    match = Placeholder.getPattern().match(base)
    reuseMap = {}
    while(match != nil)
      story_parts << match.pre_match
      placeholderString = match[1]
      placeholder = Placeholder.new(placeholderString, story_parts.size)

      # if name is reused
      if reuseMap[placeholder.name] == nil
        @placeholders << placeholder

        # if the name is reusable, add it to the reuse table
        if placeholder.reusable()
          reuseMap[placeholder.name] = placeholder
        end

        # replace the placeholder with the system generated position 
string
        story_parts << get_position_string(story_parts.size.to_s)
      else
        # for reuse placeholder, 
        # replace the placeholder with the system generated position 
string for the referenced placeholder
        story_parts << 
get_position_string(reuseMap[placeholder.name].position.to_s)
      end

      remaind = match.post_match
      match = Placeholder.getPattern().match(match.post_match)
      if (match == nil)
        story_parts << remaind
      end
    end

    @base = story_parts.join("")
  end

  def to_s
    result = @base
    @placeholders.each do |placeholder|
 result.gsub!(Regexp.new(get_position_string(placeholder.position.to_s)), 
placeholder.value)
    end
    return result
  end

  def get_position_string(position)
    "%%" + position.to_s + "%%"
  end
end

class Placeholder
  attr_accessor :name, :display_name, :position, :value

  def initialize(placeholderString, position)
    @value = ""
    @position = position

    if placeholderString.include?(":")
      @name = placeholderString.split(":")[0]
      @display_name = placeholderString.split(":")[1]
    else
      @name = placeholderString
      @display_name = placeholderString
    end
  end

  def getTemplate()
    Regexp.new(
"\\(\\(\\s*(#{name}|#{name}\\s*:\\s*#{display_name})\\s*\\)\\)")
  end

  def Placeholder.getPattern()
    /\(\(([^)]*)\)\)/
  end

  def getValueQuestion()
    "Give me #{display_name}: "
  end

  def reusable()
    name != display_name
  end
end

if $0 == __FILE__
  # read story from standard input
  story_string = ""
  ARGF.each_line do |line|
    story_string += line
  end

  # create story 
  story = Story.new(story_string)

  # request uesr to enter the corresponding value for each placeholder
  print "There are #{story.placeholders.size} placeholders.\n"
  story.placeholders.each do |placeholder|
    print placeholder.getValueQuestion()
    placeholder.value = gets().chop()
  end

  # display the story
  print story.to_s, "\n"
end
