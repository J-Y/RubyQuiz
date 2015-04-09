module MethodPrompter

       class Interactor

               # Try to include the readline library
               # if it's not available define a lower-function method
               begin
                       require 'readline'
                       Interactor.class_eval('include Readline')
               rescue Exception => ex
                       puts ex.to_s
                       warn "The Readline module is not available."
                       def readline(prompt,addHistory)
                               print prompt
                               line = gets
                               # Readline.readline returns empty string instead
                               # of "\n"
                               line = "" if line == "\n"
                               line
                       end
               end

               def initialize(target_object)
                       @target_object = target_object
               end

               def prompt_for_body(symbol, *args)
                       puts "Please define what I should do (end with a newline):"
                       method_body = []
                       line_num = 1
                       while line = readline("#{line_num}: ", true)
                               break if line.empty?
                               line_num += 1
                               method_body << line
                       end
                       method_body
               end

              def prompt_for_parms(args, block)
                       puts "There were #{args.length} arguments in the call."
                       puts "block = #{block}"
                       p args if !args.empty?
                       puts "enter method argument list"
                       args = readline("arguments: ", false)
                       args.empty? ? "" : "(#{args})"
               end

               def prompt_for_module
                       possibles = @target_object.class.ancestors.reject { |m| m == MethodPrompter }
                       result = nil
                       while result == nil
                               puts "Possible modules/classes to implement"
                               possibles.each_with_index do | mod, i |
                                       puts "  #{i}: #{mod.name}"
                               end
                               p "Enter selection(#{@target_object.class.name}): "
                               result = possibles[gets.to_i]
                       end
                       p result
                       result
               end

               def make_method(target_module, symbol, source)
                       target_module.module_eval(source, 'line', 0)
               end

               def method_source(symbol, parms, method_body)
                       "def #{symbol.to_s}#{parms}\n" <<
                            method_body.join("\n") <<
                            "\nend"
               end

               def prompt_for_method(symbol, args, block)
                       puts "#{symbol} is undefined"
                       target_module = prompt_for_module
                       parms = prompt_for_parms(args, block)
                       good_to_go = false
                       until good_to_go
                               method_body = prompt_for_body(symbol)
                               if method_body.empty?
                                       puts "Okay, nothing to do, so I've not defined #{symbol.to_s}"
                                       return
                               end
                               begin
                                       source = method_source(symbol, parms, method_body)
                                       make_method(target_module, symbol, source)
                               rescue Exception => ex
                                       puts "#{ex.class}: #{ex}"
                               ensure
                                       good_to_go = target_module.method_defined?(symbol)
                               end
                               puts "\nThat didn't work. Empty method body will give up." unless good_to_go
                       end

                       Repository.save_method(target_module, symbol, parms, method_body)
               end

       end

       class Repository

               require 'singleton'
               include Singleton

               def Repository.save_method(target_module, symbol, parms, method_body )
                       instance.module_entry(target_module).save_method(symbol,parms, method_body)
               end

               def module_entry(target_module)
                       @modules = @modules || Hash.new {|hash, k| hash[k] = ModuleEntry.new }
                       @modules[target_module]
               end

               def Repository.list_all
                       instance.list_all
               end

               def list_all
                       return "" unless @modules
                       result = ""
                       @modules.each do | mod, entry |
                            result << (mod.kind_of?(Class) ? "class ": "module ")
                            result << mod.name << "\n"
                            result << entry.list_all
                            result << "end\n"
                       end
                       result
               end

               def modules
                       @modules
               end
       end

       class ModuleEntry

               def save_method(symbol, parms, method_body)
                       @methods = @methods || Hash.new
                       @methods[symbol] = source_for(symbol, parms, method_body)
               end

               def list_all
                       return "" unless @methods
                       result = ""
                       @methods.each do | symbol, source |
                       result << source << "\n"
                       end
                       result
               end

               private
               def source_for(symbol, parms, method_body)
                       indent = " " * 8
                       source_array = [indent + "def " + symbol.to_s + parms ]
                       method_body.each do | line |
                               source_array << (indent * 2) + line
                       end
                       source_array << indent + 'end'
                       source_array.join("\n")
               end
       end

       def method_missing(symbol, *args, &block)
               Interactor.new(self).prompt_for_method(symbol, args, block)
       end

end

module Kernel
       def prompted_methods
               MethodPrompter::Repository.list_all
       end
end
