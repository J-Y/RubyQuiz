#!/usr/bin/env ruby
##################################################################
# = lexer_mw.rb - generic lexical analyser
#
# Author::        Marcel Ward   <wardies ^a-t^ gmaildotcom>
# Documentation:: Marcel Ward
# Last Modified:: Monday, 06 November 2006
#
# Solution for Ruby Quiz number 100 - http://www.rubyquiz.com/

$DEBUG = 0

# If the lexer fails to find an appropriate entry in the state
# transition table for the current character and state, it
# raises this exception.
class LexerFailure < StandardError
end

# If the lexer encounters a character for which no matching charset
# has been supplied then it raises this exception.
#
# This exception will never be raised if #init_state_transitions
# has been called with an appropriate catch-all charset id.
class InvalidLexeme < StandardError
end

class LexerMW
 # Creates an instance of the lexer class.
 #
 # _lexer_eof_ascii_::
 #   defines the ASCII byte value that the lexer considers as
 #   end-of-file when it is encountered.  When #tokenize is called,
 #   the supplied datastream is automatically appended with this
 #   character.
 def initialize(lexer_eof_ascii = 0)
   @s_trans = {}
   @columns = {}
   @lex_eof = lexer_eof_ascii
 end

 # Initialize the character set columns to be used by the lexer.
 #
 # _cs_defs_::
 #   a hash containing entries of the form <tt>id => match</tt>,
 #   where _match_ defines the characters to be matched and _id_
 #   is the id that will be passed to the finite state machine
 #   to inidicate the character grouping encountered.
 # _eof_charset_id_::
 #   defines the character set identifier which the lexer will
 #   attempt to match in the state machine table when the
 #   end-of-file character defined in #new is encountered.
 #
 # The content of _match_ falls into one of two main categories:
 #
 # _regexp_:: e.g. <tt>/\d/</tt> will match any digit 0..9; or
 # _enum_::   an enumeration that describes the set of allowed
 #            character byte values, e.g.
 #            the array <tt>[?*, ?/, ?%]</tt> matches
 #            <b>*</b>, <b>/</b> or <b>%</b>, while the range
 #            <tt>(?a..?z)</tt> matches lowercase alphas.
 #
 # e.g.
 #
 #   init_char_sets({
 #       :alphanum => /[A-Z0-9]/,
 #       :underscore => [?_],
 #       :lower_vowel => [?a, ?e, ?i, ?o, ?u],
 #       :special => (0..31)
 #     },
 #     :end_line)
 #
 # It is the responsibility of the caller to ensure that the
 # match sets for each column are mutually exclusive.
 #
 # If a 'catch-all' set is needed then it is not necessary
 # to build the set of all characters not already matched.
 # Instead, see #init_state_transitions parameter list.
 #
 # Note, the contents of the hash is duplicated and stored
 # internally to avoid any inadvertent corruption from outside.
 def init_char_sets(cs_defs, eof_charset_id = :eof)
   @charsets = {}
   # Make a verbatim copy of the lexer charset columns
   cs_defs.each_pair do
     |charset_id, match|
     @charsets[charset_id] = match.dup   # works for array/regexp
   end
   # Add an end-of-file charset column for free
   @charsets[eof_charset_id] = [@lex_eof]
   puts "@charsets =\n#{@charsets.inspect}\n\n" if $DEBUG == 1
 end

 # Initialize the state transition table that will be used by the
 # finite state machine to convert incoming characters to tokens.
 #
 # _st_::
 #   a hash that defines the state transition table to be used
 #   (see below).
 # _start_state_::
 #   defines the starting state for the finite state machine.
 # _catch_all_charset_id_::
 #   defines an optional charset id to be tried if the character
 #   currently being analysed matches none of the charsets
 #   in the charset table.  The default +nil+ ensures that the
 #   InvalidLexeme exception is raised if no charsets match.
 #
 # The state transition table hash _st_ maps each valid original
 # state to a hash containing the _rules_ to match when in that
 # state.
 #
 # Each hash entry _rule_ maps one of the character set ids
 # (defined in the call to #init_char_sets) to the _actions_ to be
 # carried out if the current character being analysed by the lexer
 # matches.
 #
 # The _action_ is a hash of distinct actions to be carried out for
 # a match.  The following actions are supported:
 #
 # <tt>:next_s => _state_</tt>::
 #   sets the finite state machine next state to be _state_ and
 #   appends the current character to the lexeme string being
 #   prepared, absorbing the current character in the datastream.
 #
 # <tt>:next_s_skip => _state_</tt>::
 #   as above but the lexeme string being prepared remains static.
 #
 # <tt>:next_s_backtrack => _state_</tt>::
 #   as for _next_s_skip_ above but does not absorb the current
 #   character (it will be used for the next state test).
 #
 # <tt>:token => _tok_</tt>::
 #   appends a hash containing a single entry to the array of
 #   generated tokens, using _tok_ as the key and a copy of the
 #   prepared lexeme string as the value.
 #
 # When the end of the datastream is reached, the lexer looks for
 # a match against charset <tt>:eof</tt>.
 #
 # When the performed actions contain no +next_s+... action, the
 # lexer assumes that a final state has been reached and returns
 # the accumulated array of tokens up to that point.
 #
 # e.g.
 #
 #   init_state_transitions({
 #     :s1 => {:alpha => {next_s = :s2},
 #             :period => {:token => :tok_period}},
 #     :s2 => {:alphanum => {next_s = :s2},
 #             :underscore => {next_s_skip == :s2},
 #             :period => {next_s_backtrack = :s1}
 #             :eof => {}}, // final state, return tokens
 #     }, :s1, :other_chars)
 #
 # Note, the contents of the hash is duplicated and stored
 # internally to avoid any inadvertent corruption from outside.
 def init_state_transitions(st, start_state = :s_start,
                            catch_all_charset_id = nil)
   @start_state = start_state
   @others_key = catch_all_charset_id
   @s_trans = {}
   # Make a verbatim copy of the state transition table
   st.each_pair do
     |orig_state, lexer_rules|
     @s_trans[orig_state] = state_rules = {}
     lexer_rules.each_pair do
       |lexer_charset, lexer_actions|
       state_rules[lexer_charset] = cur_actions = {}
       lexer_actions.each_pair do
         |action, new_val|
         cur_actions[action] = new_val
       end
     end
   end
   puts "@s_trans =\n#{@s_trans.inspect}\n\n" if $DEBUG == 1
 end

 # Tokenize the datastream in _str_ according to the specific
 # character set and state transition table initialized through
 # #init_char_sets and #init_state_transitions.
 #
 # Returns an array of token elements where each element is
 # a pair of the form:
 #
 #   [:token_name, "extracted lexeme string"]
 #
 # The end token marker [:tok_end, nil] is appended to the end
 # of the result on success, e.g.
 #
 #   tokenize(str)
 #   # => [[:tok_a, "123"], [:tok_b, "abc"], [:tok_end, nil]]
 #
 # Raises the LexerFailure exception if no matching state
 # transition is found for the current state and character.
 def tokenize(str)
   state = @start_state
   lexeme = ''
   tokens = []
   # Append our end of file marker to the string to be tokenized
   str += "%c" % @lex_eof
   str.each_byte do
     |char|
     char_as_str = "%c" % char
     loop do
       match = @charsets.find {
         |id, match|
         (match.kind_of? Regexp) ? \
           (match =~ char_as_str) : (match.include? char)
         } || [@others_key, @charsets[@others_key]] or \
           raise InvalidLexeme

       # Look for the action matching our current state and the
       # character set id for our current char.
       action = @s_trans[state][match.first] or raise LexerFailure

       # If found, action contains our hash of actions, e.g.
       # {:next_s_backtrack => :s_operator, :token => :tok_int}
       puts "#{char==@lex_eof?'<eof>':char_as_str}: " \
         "#{state.inspect} - #{action.inspect}" if $DEBUG == 1

       # Build up the lexeme unless we're backtracking or skipping
       lexeme << char_as_str if action.has_key? :next_s

       tokens << [action[:token], lexeme.dup] && lexeme = '' if \
         action.has_key? :token

       # Set the next state, or - when there is no specified next
       # state - we've finished, so return the tokens.
       state = action[:next_s] || action[:next_s_skip] ||
         action[:next_s_backtrack] or
            return tokens << [:tok_end, nil]

       break unless action.has_key? :next_s_backtrack
     end
   end
   tokens
 end
end


if $0 == __FILE__
 eval DATA.read, nil, $0, __LINE__+4
end

__END__

require 'test/unit'

class TC_LexerMW < Test::Unit::TestCase
 def test_simple
   @lexer = LexerMW.new()

   @char_sets = {
       :letter => (?a..?z),
       :digit => (/\d/),
       :space => [?\s, ?_]
     }

   @lexer.init_char_sets(@char_sets)

   @st = {
       :extract_chars => {
         :letter =>  {:next_s => :extract_chars},
         :digit =>   {:next_s => :extract_chars},
         :space =>   {:next_s_skip => :extract_chars,
                      :token => :tok_text},
         :eof =>     {:token => :tok_text}
         },
       :extract_alpha => {
         :letter =>  {:next_s => :extract_alpha},
         :digit =>   {:next_s_backtrack => :extract_num,
                      :token => :tok_alpha},
         :space =>   {:next_s_skip => :extract_alpha,
                      :token => :tok_alpha},
         :other =>   {:next_s_skip => :extract_alpha},
         :eof_exit => {}
         },
       :extract_num => {
         :letter =>  {:next_s_backtrack => :extract_alpha,
                      :token => :tok_num},
         :digit =>   {:next_s => :extract_num},
         :space =>   {:next_s_skip => :extract_num},
         :others =>  {:next_s_skip => :extract_alpha,
                      :token => :tok_num}
         }
     }
   @lexer.init_state_transitions(@st, :extract_chars)
   assert_equal [
       [:tok_text, "123"], [:tok_text, "45"],
       [:tok_text, "6"], [:tok_text, "78"],
       [:tok_text, "abcd"], [:tok_text, "efghi"],
       [:tok_text, "jklmn"], [:tok_end, nil]
     ], @lexer.tokenize("123 45 6_78 abcd efghi_jklmn")

   @lexer = LexerMW.new(?$)
   @lexer.init_char_sets(@char_sets, :eof_exit)
   @lexer.init_state_transitions(@st, :extract_num, :others)
   assert_equal [
       [:tok_num, "12345678"], [:tok_alpha, "abcd"],
       [:tok_alpha, "efghi"], [:tok_num, "445"],
       [:tok_alpha, ""], [:tok_num, "1222"], [:tok_end, nil]
     ], @lexer.tokenize("123 45 6_78 abcd efghi445!12_22!ab$45")

 end
end
