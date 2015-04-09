# $ANTLR 3.0ea7 roll.g 2006-01-09 15:33:36

require 'antlr'


class DiceCalculator < ANTLR::Parser
    TOKEN_NAMES = ["<invalid>", "<EOR>", "<DOWN>", "<UP>", "PLUS", "MINUS", "MULTI", "DIVIDE", "DICE", "PERCENT", "INTEGER", "LPAREN", "RPAREN", "WS" ]
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



    def initializeCyclicDFAs
    end

    def token_names
        TOKEN_NAMES
    end

    attr_reader :input


 



        def initialize(input)
            super(input)
            initializeMembers
            initializeCyclicDFAs
        end

        

    def initializeMembers
        
          @stack = []
        
          def result
            @stack.first
          end

    end



    # $ANTLR start parse
    # roll.g:30:1: parse : expr ;
    def parse()


        begin
            @ruleStack.push('parse')
            # roll.g:31:6: ( expr )
            # roll.g:31:6: expr

            #@following.push(FOLLOW_expr_in_parse36)
            expr()
            #@following.pop




        rescue ANTLR::RecognitionException => e
            report_error(e)
            #raise e
        ensure
            @ruleStack.pop
        end

    end
    # $ANTLR end parse



    # $ANTLR start expr
    # roll.g:34:1: expr : mexpr ( PLUS mexpr | MINUS mexpr )* ;
    def expr()


        begin
            @ruleStack.push('expr')
            # roll.g:35:6: ( mexpr ( PLUS mexpr | MINUS mexpr )* )
            # roll.g:35:6: mexpr ( PLUS mexpr | MINUS mexpr )*

            #@following.push(FOLLOW_mexpr_in_expr50)
            mexpr()
            #@following.pop


            # roll.g:36:6: ( PLUS mexpr | MINUS mexpr )*
            #catch (:loop1) do
            	while true
            		alt1 = 3
            		look_ahead1_0 = input.look_ahead(1).token_type
            		if look_ahead1_0 == PLUS  
            		    alt1 = 1
            		elsif look_ahead1_0 == MINUS  
            		    alt1 = 2

            		end

            		case alt1
            			when 1
            			    # roll.g:36:8: PLUS mexpr

            			    match(PLUS, nil) # FOLLOW_PLUS_in_expr59


            			    #@following.push(FOLLOW_mexpr_in_expr62)
            			    mexpr()
            			    #@following.pop


            			     @stack.push(@stack.pop + @stack.pop) 



            			when 2
            			    # roll.g:37:8: MINUS mexpr

            			    match(MINUS, nil) # FOLLOW_MINUS_in_expr73


            			    #@following.push(FOLLOW_mexpr_in_expr75)
            			    mexpr()
            			    #@following.pop


            			     n = @stack.pop; @stack.push(@stack.pop - n) 




            			else
            				break
            				#throw :loop1
            		end
            	end
            #end




        rescue ANTLR::RecognitionException => e
            report_error(e)
            #raise e
        ensure
            @ruleStack.pop
        end

    end
    # $ANTLR end expr



    # $ANTLR start mexpr
    # roll.g:41:1: mexpr : term ( MULTI term | DIVIDE term )* ;
    def mexpr()


        begin
            @ruleStack.push('mexpr')
            # roll.g:42:6: ( term ( MULTI term | DIVIDE term )* )
            # roll.g:42:6: term ( MULTI term | DIVIDE term )*

            #@following.push(FOLLOW_term_in_mexpr99)
            term()
            #@following.pop


            # roll.g:43:6: ( MULTI term | DIVIDE term )*
            #catch (:loop2) do
            	while true
            		alt2 = 3
            		look_ahead2_0 = input.look_ahead(1).token_type
            		if look_ahead2_0 == MULTI  
            		    alt2 = 1
            		elsif look_ahead2_0 == DIVIDE  
            		    alt2 = 2

            		end

            		case alt2
            			when 1
            			    # roll.g:43:8: MULTI term

            			    match(MULTI, nil) # FOLLOW_MULTI_in_mexpr108


            			    #@following.push(FOLLOW_term_in_mexpr111)
            			    term()
            			    #@following.pop


            			     @stack.push(@stack.pop * @stack.pop) 



            			when 2
            			    # roll.g:44:8: DIVIDE term

            			    match(DIVIDE, nil) # FOLLOW_DIVIDE_in_mexpr122


            			    #@following.push(FOLLOW_term_in_mexpr124)
            			    term()
            			    #@following.pop


            			     n = @stack.pop; @stack.push(@stack.pop / n) 




            			else
            				break
            				#throw :loop2
            		end
            	end
            #end




        rescue ANTLR::RecognitionException => e
            report_error(e)
            #raise e
        ensure
            @ruleStack.pop
        end

    end
    # $ANTLR end mexpr



    # $ANTLR start term
    # roll.g:48:1: term : ( unit | ) ( DICE ( PERCENT | unit ) )* ;
    def term()


        begin
            @ruleStack.push('term')
            # roll.g:49:6: ( ( unit | ) ( DICE ( PERCENT | unit ) )* )
            # roll.g:49:6: ( unit | ) ( DICE ( PERCENT | unit ) )*

            # roll.g:49:6: ( unit | )
            alt3 = 2
            look_ahead3_0 = input.look_ahead(1).token_type
            if (look_ahead3_0 >= INTEGER && look_ahead3_0 <= LPAREN)  
                alt3 = 1
            elsif look_ahead3_0 == -1 || (look_ahead3_0 >= PLUS && look_ahead3_0 <= DICE) || look_ahead3_0 == RPAREN  
                alt3 = 2
            else

                nvae = ANTLR::NoViableAltException.new("49:6: ( unit | )", 3, 0, @input)

                raise nvae
            end
            case alt3
                when 1
                    # roll.g:49:7: unit

                    #@following.push(FOLLOW_unit_in_term149)
                    unit()
                    #@following.pop




                when 2
                    # roll.g:49:14: 

                     @stack.push(1) 




            end


            # roll.g:50:6: ( DICE ( PERCENT | unit ) )*
            #catch (:loop5) do
            	while true
            		alt5 = 2
            		look_ahead5_0 = input.look_ahead(1).token_type
            		if look_ahead5_0 == DICE  
            		    alt5 = 1

            		end

            		case alt5
            			when 1
            			    # roll.g:50:7: DICE ( PERCENT | unit )

            			    match(DICE, nil) # FOLLOW_DICE_in_term163


            			    # roll.g:50:12: ( PERCENT | unit )
            			    alt4 = 2
            			    look_ahead4_0 = input.look_ahead(1).token_type
            			    if look_ahead4_0 == PERCENT  
            			        alt4 = 1
            			    elsif (look_ahead4_0 >= INTEGER && look_ahead4_0 <= LPAREN)  
            			        alt4 = 2
            			    else

            			        nvae = ANTLR::NoViableAltException.new("50:12: ( PERCENT | unit )", 4, 0, @input)

            			        raise nvae
            			    end
            			    case alt4
            			        when 1
            			            # roll.g:50:13: PERCENT

            			            match(PERCENT, nil) # FOLLOW_PERCENT_in_term166


            			             @stack.push(100) 



            			        when 2
            			            # roll.g:50:44: unit

            			            #@following.push(FOLLOW_unit_in_term172)
            			            unit()
            			            #@following.pop





            			    end


            			    
            			             side = @stack.pop
            			             time = @stack.pop
            			             result = 0
            			             time.times { result += rand(side) + 1 }
            			             @stack.push(result)
            			           




            			else
            				break
            				#throw :loop5
            		end
            	end
            #end




        rescue ANTLR::RecognitionException => e
            report_error(e)
            #raise e
        ensure
            @ruleStack.pop
        end

    end
    # $ANTLR end term



    # $ANTLR start unit
    # roll.g:61:1: unit : ( INTEGER | LPAREN n= expr RPAREN );
    def unit()
        token_INTEGER1 = nil
        n = nil


        begin
            @ruleStack.push('unit')
            # roll.g:62:6: ( INTEGER | LPAREN n= expr RPAREN )
            alt6 = 2
            look_ahead6_0 = input.look_ahead(1).token_type
            if look_ahead6_0 == INTEGER  
                alt6 = 1
            elsif look_ahead6_0 == LPAREN  
                alt6 = 2
            else

                nvae = ANTLR::NoViableAltException.new("61:1: unit : ( INTEGER | LPAREN n= expr RPAREN );", 6, 0, @input)

                raise nvae
            end
            case alt6
                when 1
                    # roll.g:62:6: INTEGER

                    token_INTEGER1 = input.look_ahead(1)
                    match(INTEGER, nil) # FOLLOW_INTEGER_in_unit205


                     @stack.push(token_INTEGER1.text.to_i) 



                when 2
                    # roll.g:63:6: LPAREN n= expr RPAREN

                    match(LPAREN, nil) # FOLLOW_LPAREN_in_unit214


                    #@following.push(FOLLOW_expr_in_unit218)
                    token_n = expr()
                    #@following.pop


                    match(RPAREN, nil) # FOLLOW_RPAREN_in_unit220





            end
        rescue ANTLR::RecognitionException => e
            report_error(e)
            #raise e
        ensure
            @ruleStack.pop
        end

    end
    # $ANTLR end unit



end
