#!/usr/bin/ruby -w

# Author: Shane Emmons
#
# Bracket Packing (#78)
#
# This is a pretty simple solution. I didn't want to be
# to complicated on the English translation, so instead
# of describing the packaging, I wrote out the instructions
# to manually pack the bracket(s). Thanks for a fun quiz!

class PackagingValidator

    PACKAGING_DESC = { '[' => "Insert a cardboard box.\n",
                       '{' => "Insert a wooden box.\n",
                       '(' => "Insert some soft wrapping.\n",
                       ']' => "Close the cardboard box.\n",
                       '}' => "Close the wooden box.\n",
                       ')' => "Seal the soft wrapping.\n",
                       'B' => "Insert a brace.\n" }

    def initialize( packaging )
        @packaging = packaging
    end

    def validate
        packaging_stack, brace_found = Array.new, false
        instruction_text = ''
        @packaging.split(//).each do |piece|
            case piece
            when '[', '{', '('
                brace_found = false
                packaging_stack.push(piece)
            when ']', '}', ')'
                return 1 unless brace_found
                return 1 if piece.eql?(']') and
                            not packaging_stack[-1].eql?('[')
                return 1 if piece.eql?('}') and
                            not packaging_stack[-1].eql?('{')
                return 1 if piece.eql?(')') and
                            not packaging_stack[-1].eql?('(')
                packaging_stack.pop
            when 'B'
                return 1 if packaging_stack.empty?
                brace_found = true
            else
                return 1
            end
            instruction_text << PACKAGING_DESC[piece]
        end
        return 1 unless brace_found and
                        packaging_stack.empty?
        print instruction_text.sub(/^Insert/, 'Start with')
        return 0
    end

end

if $0 == __FILE__
    print PackagingValidator.new('[{(B)}{(B)(B)}]').validate, "\n"
end
