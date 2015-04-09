# This solution provides a framework for handling user input at a higher level
# than "gets" and "chomp". Sorry to James for being so late...
#
# Usage:
#
# Define a class which inherits from HighLine::ValueInput,
# HighLine::ChoiceInput or HighLine::MenuInput, using the class methods
# (see below) to define the way the input will be handled. Then call the
# #ask class method to prompt for the input, passing additional definitions
# in an optional block (see examples at end of file).
#
#
# Class Methods (all classes):
# 
# transform <Proc object p> [, *args]
#   Calls r = p.call(r, *args), where r is the user's response
# transform symbol [, *args]
#   Calls r = r.method(symbol).call(*args)
# transform :with_my, symbol [, *args]
#   Calls r = self.method(symbol).call(r, *args), where self is an instance
#   of the class
#
#  Transformations are applied to the input in the order in which they were
#  defined, and they are inherited from parent classes cumulatively (is that
#  a word?)
#
# synonym <base string>, <synonym string> [, *<synonym strings>]
#   Creates a transformation which maps each synonym string to the
#   base string.
#
# okay_if <Proc object p> [, *args]
#   Uses the return value of p.call(r, *args) to determine if the validation
#   phase can be skipped. (r is the user's response after transformation)
# okay_if <Regexp re>
#   As above, with the result of r =~ re
# okay_if symbol [, *args]
#   As above, with the result of r.method(symbol).call(*args)
# okay_if :with_my, symbol [, *args]
#   As above, with the result of self.method(symbol).call(r, *args)
#
#  Definitions for okay values are inherited.
#
# error_message string
#   Causes the string to be printed if the validation phase fails
# error_message symbol
#   As above, with the return value from self.method(symbol).call(r)
# error_message <Proc object p>
#   As above, with the return value from p.call(r)
#
#  A class will only use one error_message definition. See the section on
#  validation below for more details about the difference in error handling
#  between ValueInput and ChoiceInput/MenuInput.
#
#
# Class Methods (ValueInput):
#
# format_hint string
#   A string which is appended to the prompt. The default 
#   ValueInput#prompt_suffix method wraps it in square brackets, e.g. 
#   "[YYYY-MM-DD]".
#
#  Format hints are inherited, but not cumulatively--if a class provides one,
#  it will override any hints in its parent classes.
#
# validate
# 
#  The syntax for the validate method is the same as that for okay_if.
#  However, procs and methods that it causes to be called have different
#  return signatures: 
#    bool                  -> indicates validity
#    bool, str_or_nil      -> as above, plus an error message that overrides
#                             any error_message definitions in the class
#    bool, str_or_nil, val -> as above, plus an alternate version of the
#                             response string
#
#  When an alternate value is returned, subsequent validations that would
#  have operated on the response string will operate on this alternate value
#  instead (see the description of the #ask method below for details on using
#  this value).
#
#  Validators are cumulatively inherited, along with the error_message
#  defintions (so if a validator from a parent class fails, the error_message
#  from that class will be used).
#
# output_format
#  
#  The syntax for output_format is the same as that for transform. It provides
#  a way to format the response after it has been validated. Like validators,
#  output format procedures will operate on the response or on the alternate
#  value if one is present.
#
#
# Class Methods (ChoiceInput, MenuInput):
#
# choices *args
#   Adds its arguments to the list of valid string responses for the class.
#   The default ChoiceInput#prompt_suffix method displays it like this--
#   "[y/(n)/m]". The parentheses indicate the default answer (see #ask below).
#
#  Instead of using validators, ChoiceInput classes simply check for a
#  response that is in the list of choices.
#
# header string
#   (MenuInput only) A string that is printed before the list of choices is
#   displayed.
#
# items *args
#   (MenuInput only) The arguments are matched to the choices.
#
#  When one of the choices is selected, the matching element in the list of
#  items is returned as the alternate value. The default
#  MenuInput#prompt_suffix displays the header string, and one line for each
#  choice in the format "#{choice[i]}\t#{item[i]}\n".
#
# The #ask method
#
# ask(prompt, default_value=nil)
#
#  When the ask method is called, things get done in this order:
#  1. The prompt is printed, with the result of #prompt_suffix appended.
#  2. $stdin_gets is called, and the raw input is saved.
#  3. All defined transformations are applied to the response.
#  4. If any okay_if tests pass, the response is returned.
#  5. If the response is empty, and there is a default_value, the default is
#     returned.
#  6. Validation occurs. For ChoiceInput/MenuInput, this just involves
#     matching the response to the list of choices. For ValueInput, all
#     defined validation tests are run.
#  7. If validation succeeded, all output_format rules are applied.
#  8. If validation failed, and an error message was returned, it is printed,
#     and the process loops back to step 1.
#
#  The return value is an object of class ResponseString, which is a subclass
#  of normal String. It provides a #raw_input method, an #error_message method,
#  a #valid? method, and and #alternate method, for getting details about the
#  response.

module HighLine

  class BaseInput

    def self.get_error_message
      @em ||= nil
    end

    def self.error_message(em)
      @em = em
    end

    def self.get_transformers
      @ts ||= []
    end

    def self.transform(*ts)
      @ts ||= []
      @ts << ts
    end

    def self.get_okays
      @oi ||= []
    end

    def self.okay_if(*oi)
      @oi ||= []
      @oi << oi
    end

    def self.synonym(*syns)
      default = syns[0]
      synonyms = syns[1..-1]
      transform :with_my, :synonymize, synonyms, default
    end

    def self.ask(prompt, default_response=nil, &block)
      prompt = prompt + " " if prompt !~ /\s$/ and !prompt.empty?
      if block_given?
        klass = Class.new(self, &block)
      else
        klass = self
      end
      inputter = klass.new(default_response)
      while true
        print prompt
        $stdout.flush
        response = inputter.gets
        break if response.valid?
        if response.error_message
          puts response.error_message
          $stdout.flush
        end
      end
      return response
    end

    def initialize(default_response)
      @default_response = default_response
      @klasses = []
      klass = self.class
      while klass.respond_to? :get_transformers
        @klasses.unshift(klass)
        klass = klass.superclass
      end
      @okays = @klasses.collect { |klass|
        curry_okays(klass.get_okays)
      }.flatten
      @transformers = @klasses.collect { |klass|
        curry_transformers(klass.get_transformers)
      }.flatten
    end

    def gets
      print prompt_suffix
      $stdout.flush
      raw_input = $stdin.gets.chomp
      response = raw_input.dup
      @transformers.each do |transformer|
        response = transformer.call(response)
      end
      if @default_response and response.empty?
        return ResponseString.new(@default_response, raw_input, true)
      end

      @okays.each do |okay|
        if okay.call(response)
          return ResponseString.new(response, raw_input, true)
        end
      end

      do_validate(response, raw_input)
    end

    def prompt_suffix
      if @default_response and !@default_response.empty?
        "(#{@default_response}) "
      else
        ""
      end
    end

    def synonymize(r, synonyms, default)
      return r unless synonyms.member? r
      default
    end

    def curry_error_message(klass_error_message)
      case klass_error_message
      when Symbol
        proc { |r| method(klass_error_message).call(r) }
      when Proc
        proc { |r| klass_error_message.call(r) }
      when String
        proc { |r| klass_error_message }
      end
    end

    def curry_transformers(klass_transformers)
      klass_transformers.collect do |transformer|
        p_name = transformer[0]
        args = transformer[1..-1]
        case p_name
        when Symbol
          if p_name == :with_my
            proc { |r| method(args[0]).call(r, *args[1..-1]) }
          else
            proc { |r| r.method(p_name).call(*args) }
          end
        when Proc
          proc { |r| p_name.call(r, *args) }
        end
      end
    end

    def curry_okays(klass_okays)
      klass_okays.collect { |okay|
        p_name = okay[0]
        args = okay[1..-1]
        case p_name
        when Symbol
          if p_name == :with_my
            proc { |r| method(args[0]).call(r, *args[1..-1]) }
          else
            proc { |r| r.method(p_name).call(*args) }
          end
        when Regexp
          proc { |r| r.to_s =~ p_name }
        when Proc
          proc { |r| p_name.call(r, *args) }
        end
      }.compact
    end

    def do_validate(response, raw_input)
      ResponseString.new(response, raw_input, true)
    end
  end

  class ValueInput < BaseInput

    def self.get_validators
      @vld ||= []
    end

    def self.validate(*vld)
      @vld ||= []
      @vld << vld
    end

    def self.get_output_formats
      @of ||= []
    end

    def self.output_format(*of)
      @of ||= []
      @of << of
    end

    def self.get_format_hint
      @fh ||= nil
    end

    def self.format_hint(fh)
      @fh = fh
    end

    def initialize(default_response)
      super
      klasses = @klasses[1..-1]
      @validators = klasses.collect { |klass|
        curry_okays(klass.get_validators)
      }
      @error_messages = klasses.collect do |klass|
        curry_error_message(klass.get_error_message)
      end
      @output_formats = klasses.collect { |klass|
        curry_transformers(klass.get_output_formats)
      }.flatten
      klasses.reverse.each do |klass|
        @format_hint = klass.get_format_hint
        break if @format_hint
      end
    end

    def prompt_suffix
      super << (@format_hint ? "[#{@format_hint}] " : "")
    end

    def do_validate(response, raw_input)
      valid = true
      err_msg = nil
      @alternate = nil
      resp = response
      @validators.each_index do |i|
        @validators[i].each do |validator|
          error_message = nil
          valid, err_msg, alt = validator.call(resp)
          if !valid and !err_msg
            while !@error_messages[i]
              i = i + 1
              break if i == @error_messages.length
            end
            klass_error_message = @error_messages[i]
            err_msg = klass_error_message.call(resp) if klass_error_message
          end
          if alt
            resp = alt
            @alternate = alt
          end
          break unless valid
        end
        break unless valid
      end
      resp = response if @output_formats.empty?
      @output_formats.each do |output_format|
        resp = output_format.call(resp)
      end
      ResponseString.new(resp, raw_input, valid, err_msg, @alternate)
    end
  end

  class ChoiceInput < BaseInput
    error_message :default_error_message

    def self.get_choices
      @cs ||= []
    end

    def self.choices(*cs)
      if !get_choices.empty?
        raise SyntaxError, "cannot add multiple choice sets", caller
      end
      @cs = cs
    end

    def initialize(default_response)
      super
      @choices = self.class.get_choices
      @klasses.reverse.each do |klass|
        @error_message = curry_error_message(klass.get_error_message)
        break if @error_message
      end
    end

    def wrap_default(choice)
      choice == @default_response ? "(#{choice})" : choice
    end

    def prompt_suffix
      "[" + @choices.collect { |ch| wrap_default(ch) }.join('/') + "] "
    end

    def default_error_message(response)
      "Please enter one of #{@choices[0..-2].join(', ')} or #{@choices[-1]}"
    end

    def do_validate(response, raw_input)
      error_message = nil
      valid = @choices.member? response
      if !valid
        error_message = @error_message.call(response)
      end
      ResponseString.new(response, raw_input, valid, error_message)
    end
  end

  class MenuInput < ChoiceInput

    def self.get_items
      @its ||= []
    end

    def self.items(*its)
      @its ||= []
      if get_choices.empty?
        raise SyntaxError, "choices must be added before items", caller
      end
      if its.length != @cs.length
        raise SyntaxError, "number of items must match choices", caller
      end
      @its = its
    end

    def self.get_header
      @hdr ||= nil
    end

    def self.header(hdr)
      @hdr = hdr
    end

    def initialize(default_response)
      super
      klasses = @klasses[2..-1]
      @items = self.class.get_items
      klasses.reverse.each do |klass|
        @header = klass.get_header
        break if @header
      end
    end

    def prompt_suffix
      if @header
        ps = "#{@header}\n"
      else
        ps = "\n"
      end
      0.upto(@choices.length - 1) do |i|
        ps << " " if @choices[i] != @default_response
        ps << wrap_default(@choices[i]) + "\t" + @items[i] + "\n"
      end
      return ps
    end

    def default_error_message(response)
      "Please select one of the given options"
    end

    def do_validate(response, raw_input)
      rs = super
      rs.alternate = @items[@choices.index(response)] if rs.valid?
      rs
    end
  end

  class ResponseString < String
    attr_accessor :alternate
    attr_reader :error_message, :raw_input

    def initialize(resp, raw, valid, err_msg=nil, alt=nil)
      @raw_input = raw
      @valid = valid
      @error_message = err_msg
      @alternate = alt || resp
      super(resp)
    end

    def valid?
      @valid
    end
  end

end

if __FILE__ == $0

require 'date'

class IntegerInput < HighLine::ValueInput
  validate /^\d+$/
  validate proc { |r| [true, nil, r.to_i] }
end

puts IntegerInput.ask("Enter a number from 1 to 10, or Q to quit:") {
  okay_if /^q$/i
  validate :between?, 1, 10
}

class DateInput < HighLine::ValueInput
  validate :with_my, :check_date

  def check_date(r)
    begin
      test_date = Date.parse(r)
    rescue
      false
    else
      [true, nil, test_date]
    end
  end
end

puts DateInput.ask("Enter a date:") {
  output_format :to_s
  error_message "That is not a date!"
}

class YesOrNo < HighLine::ChoiceInput
  transform :downcase
  choices "y", "n"
  synonym "y", "yes", "oui", "si"
end

puts YesOrNo.ask("Is your computer turned on?", "y") 

class EditorMenu < HighLine::MenuInput
  header "Please select an editor:"
  choices "1", "2", "3"
  items "vim", "vim", "vim"
  error_message "There are no other editors!"
end

puts EditorMenu.ask("", "1").alternate

end
