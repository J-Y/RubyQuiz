# $ANTLR 3.0ea7 Dice.lexer.g 2006-01-08 02:25:17

require 'antlr'


class DiceLexer < ANTLR::Lexer
    T10=10
    T6=6
    T11=11
    T9=9
    WS=5
    NUMBER=4
    T12=12
    T8=8
    T13=13
    T7=7

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

    def match_token_T6()
        type = T6
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('T6')
        # Dice.lexer.g:7:6: ( '+' )
        # Dice.lexer.g:7:6: '+'

        match(?+)




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_T7()
        type = T7
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('T7')
        # Dice.lexer.g:8:6: ( '-' )
        # Dice.lexer.g:8:6: '-'

        match(?-)




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_T8()
        type = T8
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('T8')
        # Dice.lexer.g:9:6: ( '*' )
        # Dice.lexer.g:9:6: '*'

        match(?*)




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_T9()
        type = T9
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('T9')
        # Dice.lexer.g:10:6: ( '/' )
        # Dice.lexer.g:10:6: '/'

        match(?/)




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_T10()
        type = T10
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('T10')
        # Dice.lexer.g:11:7: ( 'd' )
        # Dice.lexer.g:11:7: 'd'

        match(?d)




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_T11()
        type = T11
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('T11')
        # Dice.lexer.g:12:7: ( '%' )
        # Dice.lexer.g:12:7: '%'

        match(?%)




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_T12()
        type = T12
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('T12')
        # Dice.lexer.g:13:7: ( '(' )
        # Dice.lexer.g:13:7: '('

        match(?()




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_T13()
        type = T13
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('T13')
        # Dice.lexer.g:14:7: ( ')' )
        # Dice.lexer.g:14:7: ')'

        match(?))




        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_token_NUMBER()
        type = NUMBER
        start = @input.index
        line = @input.line
        column = @input.column
        channel = ANTLR::Token::DEFAULT_CHANNEL
        @ruleStack.push('NUMBER')
        # Dice.lexer.g:16:10: ( ( '0' .. '9' )+ )
        # Dice.lexer.g:16:10: ( '0' .. '9' )+

        # Dice.lexer.g:16:10: ( '0' .. '9' )+
        cnt1=0
        #catch (:loop1) do
        	while true
            	alt1 = 2
        		look_ahead1_0 = input.look_ahead(1)
        		if (look_ahead1_0 >= ?0 && look_ahead1_0 <= ?9)  
        		    alt1 = 1

        		end

        		case alt1
        			when 1
        			    # Dice.lexer.g:16:12: '0' .. '9'

        			    match_range(?0,?9); 




        			else
        				#throw :loop1 if cnt1 >= 1
        				break if cnt1 >= 1
        				eee = ANTLR::EarlyExitException.new(1, @input)
        				raise eee
        		end
        		cnt1 = cnt1 + 1
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
        # Dice.lexer.g:18:6: ( ( (' '|'\n'|'\t'))+ )
        # Dice.lexer.g:18:6: ( (' '|'\n'|'\t'))+

        # Dice.lexer.g:18:6: ( (' '|'\n'|'\t'))+
        cnt2=0
        #catch (:loop2) do
        	while true
            	alt2 = 2
        		look_ahead2_0 = input.look_ahead(1)
        		if (look_ahead2_0 >= ?\t && look_ahead2_0 <= ?\n) || look_ahead2_0 == ?\s  
        		    alt2 = 1

        		end

        		case alt2
        			when 1
        			    # Dice.lexer.g:18:8: (' '|'\n'|'\t')

        			    if (input.look_ahead(1) >= ?\t && input.look_ahead(1) <= ?\n) || input.look_ahead(1) == ?\s
        			        @input.consume
        			        @errorRecovery=false
        			    else
        			        mse = ANTLR::MismatchedSetException.new(nil, @input)
        			        #recover(mse)

        			        raise mse
        			    end





        			else
        				#throw :loop2 if cnt2 >= 1
        				break if cnt2 >= 1
        				eee = ANTLR::EarlyExitException.new(2, @input)
        				raise eee
        		end
        		cnt2 = cnt2 + 1
        	end
        #end


         channel = 99 



        @ruleStack.pop
        if @token.nil?
            @token = ANTLR::Token.new(type, channel, @input, start, @input.index - 1)

            @token.line = line
            @token.column = column
        end

    end

    def match_tokens
        # Dice.lexer.g:1:10: ( T6 | T7 | T8 | T9 | T10 | T11 | T12 | T13 | NUMBER | WS )
        alt3 = 10
        case input.look_ahead(1)
        when ?+ :
            alt3 = 1
        when ?- :
            alt3 = 2
        when ?* :
            alt3 = 3
        when ?/ :
            alt3 = 4
        when ?d :
            alt3 = 5
        when ?% :
            alt3 = 6
        when ?( :
            alt3 = 7
        when ?) :
            alt3 = 8
        when ?0,?1,?2,?3,?4,?5,?6,?7,?8,?9 :
            alt3 = 9
        when ?\t,?\n,?\s :
            alt3 = 10
        else

            nvae = ANTLR::NoViableAltException.new("1:1: Tokens : ( T6 | T7 | T8 | T9 | T10 | T11 | T12 | T13 | NUMBER | WS );", 3, 0, @input)
            raise nvae
        end
        case alt3
            when 1
                # Dice.lexer.g:1:10: T6

                match_token_T6()




            when 2
                # Dice.lexer.g:1:13: T7

                match_token_T7()




            when 3
                # Dice.lexer.g:1:16: T8

                match_token_T8()




            when 4
                # Dice.lexer.g:1:19: T9

                match_token_T9()




            when 5
                # Dice.lexer.g:1:22: T10

                match_token_T10()




            when 6
                # Dice.lexer.g:1:26: T11

                match_token_T11()




            when 7
                # Dice.lexer.g:1:30: T12

                match_token_T12()




            when 8
                # Dice.lexer.g:1:34: T13

                match_token_T13()




            when 9
                # Dice.lexer.g:1:38: NUMBER

                match_token_NUMBER()




            when 10
                # Dice.lexer.g:1:45: WS

                match_token_WS()





        end

    end


    def initializeCyclicDFAs
    end
end