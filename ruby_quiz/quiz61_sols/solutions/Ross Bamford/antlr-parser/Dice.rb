# $ANTLR 3.0ea7 dice.g 2006-01-08 02:25:17

require 'antlr'


class Dice < ANTLR::Parser
    TOKEN_NAMES = ["<invalid>", "<EOR>", "<DOWN>", "<UP>", "NUMBER", "WS", "\'+\'", "\'-\'", "\'*\'", "\'/\'", "\'d\'", "\'%\'", "\'(\'", "\')\'" ]
    WS=5
    NUMBER=4



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
          @roll_proc = lambda { |sides| Integer((rand * sides) + 1) }

          class << self
            def result; @stack[0]; end
            def roll_proc; @roll_proc; end
            def roll_proc=(p); @roll_proc = p; end

            private
            def dbg(*s); puts(*s) if $VERBOSE; end
          end

    end



    # $ANTLR start parse
    # dice.g:42:1: parse : expr ;
    def parse()


        begin
            @ruleStack.push('parse')
            # dice.g:42:8: ( expr )
            # dice.g:42:8: expr

            #@following.push(FOLLOW_expr_in_parse50)
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
    # dice.g:52:1: expr : mult ( '+' mult | '-' mult )* ;
    def expr()


        begin
            @ruleStack.push('expr')
            # dice.g:52:7: ( mult ( '+' mult | '-' mult )* )
            # dice.g:52:7: mult ( '+' mult | '-' mult )*

            #@following.push(FOLLOW_mult_in_expr65)
            mult()
            #@following.pop


            # dice.g:52:12: ( '+' mult | '-' mult )*
            #catch (:loop1) do
            	while true
            		alt1 = 3
            		look_ahead1_0 = input.look_ahead(1).token_type
            		if look_ahead1_0 == 6  
            		    alt1 = 1
            		elsif look_ahead1_0 == 7  
            		    alt1 = 2

            		end

            		case alt1
            			when 1
            			    # dice.g:53:5: '+' mult

            			    match(6, nil) # FOLLOW_6_in_expr73


            			    #@following.push(FOLLOW_mult_in_expr75)
            			    mult()
            			    #@following.pop



            			          a, b = @stack.pop, @stack.pop
            			          dbg "\nAdd: #{b} + #{a}"
            			          @stack.push(b + a)
            			        



            			when 2
            			    # dice.g:58:5: '-' mult

            			    match(7, nil) # FOLLOW_7_in_expr83


            			    #@following.push(FOLLOW_mult_in_expr85)
            			    mult()
            			    #@following.pop



            			          a, b = @stack.pop, @stack.pop
            			          dbg "\nSubtract: #{b} - #{a}"
            			          @stack.push(b - a)
            			        




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



    # $ANTLR start mult
    # dice.g:65:1: mult : dice ( '*' dice | '/' dice )* ;
    def mult()


        begin
            @ruleStack.push('mult')
            # dice.g:65:7: ( dice ( '*' dice | '/' dice )* )
            # dice.g:65:7: dice ( '*' dice | '/' dice )*

            #@following.push(FOLLOW_dice_in_mult100)
            dice()
            #@following.pop


            # dice.g:65:12: ( '*' dice | '/' dice )*
            #catch (:loop2) do
            	while true
            		alt2 = 3
            		look_ahead2_0 = input.look_ahead(1).token_type
            		if look_ahead2_0 == 8  
            		    alt2 = 1
            		elsif look_ahead2_0 == 9  
            		    alt2 = 2

            		end

            		case alt2
            			when 1
            			    # dice.g:66:5: '*' dice

            			    match(8, nil) # FOLLOW_8_in_mult108


            			    #@following.push(FOLLOW_dice_in_mult110)
            			    dice()
            			    #@following.pop



            			          a, b = @stack.pop, @stack.pop
            			          dbg "\nMultiply: #{b} * #{a}"
            			          @stack.push(b * a)
            			        



            			when 2
            			    # dice.g:71:5: '/' dice

            			    match(9, nil) # FOLLOW_9_in_mult118


            			    #@following.push(FOLLOW_dice_in_mult120)
            			    dice()
            			    #@following.pop


            			          
            			          a, b = @stack.pop, @stack.pop
            			          dbg "\nDivide: #{b} / #{a}"
            			          @stack.push(b / a)
            			        




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
    # $ANTLR end mult



    # $ANTLR start dice
    # dice.g:88:1: dice : ( atom ( 'd' ( cent | atom ) )* | ( 'd' ( cent | atom ) )* );
    def dice()


        begin
            @ruleStack.push('dice')
            # dice.g:88:7: ( atom ( 'd' ( cent | atom ) )* | ( 'd' ( cent | atom ) )* )
            alt7 = 2
            look_ahead7_0 = input.look_ahead(1).token_type
            if look_ahead7_0 == NUMBER || look_ahead7_0 == 12  
                alt7 = 1
            elsif look_ahead7_0 == -1 || (look_ahead7_0 >= 6 && look_ahead7_0 <= 10) || look_ahead7_0 == 13  
                alt7 = 2
            else

                nvae = ANTLR::NoViableAltException.new("88:1: dice : ( atom ( \'d\' ( cent | atom ) )* | ( \'d\' ( cent | atom ) )* );", 7, 0, @input)

                raise nvae
            end
            case alt7
                when 1
                    # dice.g:88:7: atom ( 'd' ( cent | atom ) )*

                    #@following.push(FOLLOW_atom_in_dice145)
                    atom()
                    #@following.pop


                    # dice.g:88:12: ( 'd' ( cent | atom ) )*
                    #catch (:loop4) do
                    	while true
                    		alt4 = 2
                    		look_ahead4_0 = input.look_ahead(1).token_type
                    		if look_ahead4_0 == 10  
                    		    alt4 = 1

                    		end

                    		case alt4
                    			when 1
                    			    # dice.g:88:13: 'd' ( cent | atom )

                    			    match(10, nil) # FOLLOW_10_in_dice148


                    			    # dice.g:88:17: ( cent | atom )
                    			    alt3 = 2
                    			    look_ahead3_0 = input.look_ahead(1).token_type
                    			    if look_ahead3_0 == 11  
                    			        alt3 = 1
                    			    elsif look_ahead3_0 == NUMBER || look_ahead3_0 == 12  
                    			        alt3 = 2
                    			    else

                    			        nvae = ANTLR::NoViableAltException.new("88:17: ( cent | atom )", 3, 0, @input)

                    			        raise nvae
                    			    end
                    			    case alt3
                    			        when 1
                    			            # dice.g:88:18: cent

                    			            #@following.push(FOLLOW_cent_in_dice151)
                    			            cent()
                    			            #@following.pop




                    			        when 2
                    			            # dice.g:88:25: atom

                    			            #@following.push(FOLLOW_atom_in_dice155)
                    			            atom()
                    			            #@following.pop





                    			    end



                    			          sides, num_rolls = @stack.pop, @stack.pop || 1
                    			          dbg "\nRoll: #{sides} sides, #{num_rolls} rolls"    

                    			          this_roll = 0
                    			          num_rolls.times do |i|
                    			            this_roll += (tr = @roll_proc[sides])
                    			            dbg "    roll#{i+1} = #{tr}"
                    			          end

                    			          @stack.push(this_roll)
                    			          dbg "  total = #{this_roll}"
                    			        




                    			else
                    				break
                    				#throw :loop4
                    		end
                    	end
                    #end




                when 2
                    # dice.g:101:5: ( 'd' ( cent | atom ) )*

                    # dice.g:101:5: ( 'd' ( cent | atom ) )*
                    #catch (:loop6) do
                    	while true
                    		alt6 = 2
                    		look_ahead6_0 = input.look_ahead(1).token_type
                    		if look_ahead6_0 == 10  
                    		    alt6 = 1

                    		end

                    		case alt6
                    			when 1
                    			    # dice.g:101:6: 'd' ( cent | atom )

                    			    match(10, nil) # FOLLOW_10_in_dice167


                    			    # dice.g:101:10: ( cent | atom )
                    			    alt5 = 2
                    			    look_ahead5_0 = input.look_ahead(1).token_type
                    			    if look_ahead5_0 == 11  
                    			        alt5 = 1
                    			    elsif look_ahead5_0 == NUMBER || look_ahead5_0 == 12  
                    			        alt5 = 2
                    			    else

                    			        nvae = ANTLR::NoViableAltException.new("101:10: ( cent | atom )", 5, 0, @input)

                    			        raise nvae
                    			    end
                    			    case alt5
                    			        when 1
                    			            # dice.g:101:11: cent

                    			            #@following.push(FOLLOW_cent_in_dice170)
                    			            cent()
                    			            #@following.pop




                    			        when 2
                    			            # dice.g:101:18: atom

                    			            #@following.push(FOLLOW_atom_in_dice174)
                    			            atom()
                    			            #@following.pop





                    			    end



                    			          @stack.push(tr = @roll_proc[sides = @stack.pop])
                    			          dbg "\nRoll: #{sides} sides, 1 roll"    
                    			          dbg "    roll1 = #{tr}\n  total = #{tr}"    
                    			        




                    			else
                    				break
                    				#throw :loop6
                    		end
                    	end
                    #end





            end
        rescue ANTLR::RecognitionException => e
            report_error(e)
            #raise e
        ensure
            @ruleStack.pop
        end

    end
    # $ANTLR end dice



    # $ANTLR start cent
    # dice.g:110:1: protected cent : '%' ;
    def cent()


        begin
            @ruleStack.push('cent')
            # dice.g:110:7: ( '%' )
            # dice.g:110:7: '%'

            match(11, nil) # FOLLOW_11_in_cent192


             @stack.push(100) 



        rescue ANTLR::RecognitionException => e
            report_error(e)
            #raise e
        ensure
            @ruleStack.pop
        end

    end
    # $ANTLR end cent



    # $ANTLR start atom
    # dice.g:119:1: atom : (n= NUMBER | '(' expr ')' );
    def atom()
        token_n = nil

        begin
            @ruleStack.push('atom')
            # dice.g:119:7: (n= NUMBER | '(' expr ')' )
            alt8 = 2
            look_ahead8_0 = input.look_ahead(1).token_type
            if look_ahead8_0 == NUMBER  
                alt8 = 1
            elsif look_ahead8_0 == 12  
                alt8 = 2
            else

                nvae = ANTLR::NoViableAltException.new("119:1: atom : (n= NUMBER | \'(\' expr \')\' );", 8, 0, @input)

                raise nvae
            end
            case alt8
                when 1
                    # dice.g:119:7: n= NUMBER

                    token_n = input.look_ahead(1)
                    match(NUMBER, nil) # FOLLOW_NUMBER_in_atom210


                     @stack.push(token_n.text.to_i) 



                when 2
                    # dice.g:120:7: '(' expr ')'

                    match(12, nil) # FOLLOW_12_in_atom220


                    #@following.push(FOLLOW_expr_in_atom222)
                    expr()
                    #@following.pop


                    match(13, nil) # FOLLOW_13_in_atom224





            end
        rescue ANTLR::RecognitionException => e
            report_error(e)
            #raise e
        ensure
            @ruleStack.pop
        end

    end
    # $ANTLR end atom



end
