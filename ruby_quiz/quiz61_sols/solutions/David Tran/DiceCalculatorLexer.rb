# $ANTLR 3.0ea7 DiceCalculator.lexer.g 2006-01-09 15:33:36

require 'antlr'


class DiceCalculatorLexer < ANTLR::Lexer
    INTEGER=10
    MINUS=5
    DIVIDE=7
    PERCENT=9
    WS=13
    RPAREN=12
    LPAREN=11
    PLUS=4
    MULTI=6
    DICE=8

    def initialize(input)
        super(input)
        initializeMembers
        initializeCyclicDFAs
    end

    def initializeMembers
    end

    attr_reader :input

    def next_token
        while true do
            return ANTLR::Token::EOF if @input.look_ahead(1) == ANTLR::CharStream::EOF

            @token = nil
            begin
                match_tokens
                return @token
            rescue ANTLR::RecognitionException => e
                report_error(e)
                STDERR << "consuming char #{convert(@input.look_ahead(1))} during recovery\n"
                @input.consume
                #raise e
            end
        end
    end

    def match_token_LPAREN()
        type = LPAREN
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('LPAREN')
        # DiceCalculator.lexer.g:7:10: ( '(' )
        # DiceCalculator.lexer.g:7:10: '('

        match(?()




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_RPAREN()
        type = RPAREN
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('RPAREN')
        # DiceCalculator.lexer.g:9:10: ( ')' )
        # DiceCalculator.lexer.g:9:10: ')'

        match(?))




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_PLUS()
        type = PLUS
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('PLUS')
        # DiceCalculator.lexer.g:11:8: ( '+' )
        # DiceCalculator.lexer.g:11:8: '+'

        match(?+)




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_MINUS()
        type = MINUS
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('MINUS')
        # DiceCalculator.lexer.g:13:9: ( '-' )
        # DiceCalculator.lexer.g:13:9: '-'

        match(?-)




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_MULTI()
        type = MULTI
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('MULTI')
        # DiceCalculator.lexer.g:15:9: ( '*' )
        # DiceCalculator.lexer.g:15:9: '*'

        match(?*)




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_DIVIDE()
        type = DIVIDE
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('DIVIDE')
        # DiceCalculator.lexer.g:17:10: ( '/' )
        # DiceCalculator.lexer.g:17:10: '/'

        match(?/)




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_PERCENT()
        type = PERCENT
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('PERCENT')
        # DiceCalculator.lexer.g:19:11: ( '%' )
        # DiceCalculator.lexer.g:19:11: '%'

        match(?%)




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_DICE()
        type = DICE
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('DICE')
        # DiceCalculator.lexer.g:21:8: ( 'd' )
        # DiceCalculator.lexer.g:21:8: 'd'

        match(?d)




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_INTEGER()
        type = INTEGER
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('INTEGER')
        # DiceCalculator.lexer.g:23:11: ( ( '1' .. '9' ) ( '0' .. '9' )* )
        # DiceCalculator.lexer.g:23:11: ( '1' .. '9' ) ( '0' .. '9' )*

        # DiceCalculator.lexer.g:23:11: ( '1' .. '9' )
        # DiceCalculator.lexer.g:23:13: '1' .. '9'

        match_range(?1,?9); 




        # DiceCalculator.lexer.g:23:26: ( '0' .. '9' )*
        #catch (:loop1) do
        	while true
        		alt1 = 2
        		look_ahead1_0 = input.look_ahead(1)
        		if (look_ahead1_0 >= ?0 && look_ahead1_0 <= ?9)  
        		    alt1 = 1

        		end

        		case alt1
        			when 1
        			    # DiceCalculator.lexer.g:23:28: '0' .. '9'

        			    match_range(?0,?9); 




        			else
        				break
        				#throw :loop1
        		end
        	end
        #end




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_WS()
        type = WS
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('WS')
        # DiceCalculator.lexer.g:25:6: ( (' '|'\t'|'\n'|'\r'))
        # DiceCalculator.lexer.g:25:6: (' '|'\t'|'\n'|'\r')

        if (input.look_ahead(1) >= ?\t && input.look_ahead(1) <= ?\n) || input.look_ahead(1) == ?\r || input.look_ahead(1) == ?\s
            @input.consume
            @errorRecovery=false
        else
            mse = ANTLR::MismatchedSetException.new(nil, @input)
            #recover(mse)

            raise mse
        end


         channel = 99; 



        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_tokens
        # DiceCalculator.lexer.g:1:10: ( LPAREN | RPAREN | PLUS | MINUS | MULTI | DIVIDE | PERCENT | DICE | INTEGER | WS )
        alt2 = 10
        case input.look_ahead(1)
        when ?( :
            alt2 = 1
        when ?) :
            alt2 = 2
        when ?+ :
            alt2 = 3
        when ?- :
            alt2 = 4
        when ?* :
            alt2 = 5
        when ?/ :
            alt2 = 6
        when ?% :
            alt2 = 7
        when ?d :
            alt2 = 8
        when ?1,?2,?3,?4,?5,?6,?7,?8,?9 :
            alt2 = 9
        when ?\t,?\n,?\r,?\s :
            alt2 = 10
        else

            nvae = ANTLR::NoViableAltException.new("1:1: Tokens : ( LPAREN | RPAREN | PLUS | MINUS | MULTI | DIVIDE | PERCENT | DICE | INTEGER | WS );", 2, 0, @input)
            raise nvae
        end
        case alt2
            when 1
                # DiceCalculator.lexer.g:1:10: LPAREN

                match_token_LPAREN()




            when 2
                # DiceCalculator.lexer.g:1:17: RPAREN

                match_token_RPAREN()




            when 3
                # DiceCalculator.lexer.g:1:24: PLUS

                match_token_PLUS()




            when 4
                # DiceCalculator.lexer.g:1:29: MINUS

                match_token_MINUS()




            when 5
                # DiceCalculator.lexer.g:1:35: MULTI

                match_token_MULTI()




            when 6
                # DiceCalculator.lexer.g:1:41: DIVIDE

                match_token_DIVIDE()




            when 7
                # DiceCalculator.lexer.g:1:48: PERCENT

                match_token_PERCENT()




            when 8
                # DiceCalculator.lexer.g:1:56: DICE

                match_token_DICE()




            when 9
                # DiceCalculator.lexer.g:1:61: INTEGER

                match_token_INTEGER()




            when 10
                # DiceCalculator.lexer.g:1:69: WS

                match_token_WS()





        end

    end


    def initializeCyclicDFAs
    end
end