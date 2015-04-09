require 'sandbox'

class Compiler
  class << self
    def sb
      unless @sb
        @sb = Sandbox.new

        @sb.eval <<-EOC
          class Object
            private
            def ldconsts(o)
              if (o > -32769) && (o < 32768)
                [].push(0x01, *[o].pack('n').unpack('C*'))
              else
                [].push(0x02, *[o].pack('N').unpack('C*'))
              end
            end
          end

          class Fixnum
            def +(o)
              if o.is_a? Array
                o.push(*ldconsts(self)).push(0x0a)
              else
                ldconsts(self).push(*ldconsts(o)).push(0x0a)
              end
            end

            def -(o)
              if o.is_a? Array
                o.push(*ldconsts(self)).push(0xa0, 0x0b)
              else
                ldconsts(self).push(*ldconsts(o)).push(0x0b)
              end
            end

            def *(o)
              if o.is_a? Array
                o.push(*ldconsts(self)).push(0x0c)
              else
                ldconsts(self).push(*ldconsts(o)).push(0x0c)
              end
            end

            def **(o)
              if o.is_a? Array
                o.push(*ldconsts(self)).push(0xa0, 0x0d)
              else
                ldconsts(self).push(*ldconsts(o)).push(0x0d)
              end
            end

            def /(o)
              if o.is_a? Array
                o.push(*ldconsts(self)).push(0xa0, 0x0e)
              else
                ldconsts(self).push(*ldconsts(o)).push(0x0e)
              end
            end

            def %(o)
              if o.is_a? Array
                o.push(*ldconsts(self)).push(0xa0, 0x0f)
              else
                ldconsts(self).push(*ldconsts(o)).push(0x0f)
              end
            end
          end

          class Array
            def +(o)
              if o.is_a? Array
                o.push(*self).push(0x0a)
              else
                self.push(*ldconsts(o)).push(0x0a)
              end
            end

            def -(o)
              if o.is_a? Array
                o.push(*self).push(0xa0, 0x0b)
              else
                self.push(*ldconsts(o)).push(0x0b)
              end
            end

            def *(o)
              if o.is_a? Array
                o.push(*self).push(0x0c)
              else
                self.push(*ldconsts(o)).push(0x0c)
              end
            end

            def **(o)
              if o.is_a? Array
                o.push(*self).push(0xa0, 0x0d)
              else
                self.push(*ldconsts(o)).push(0x0d)
              end
            end

            def /(o)
              if o.is_a? Array
                o.push(*self).push(0xa0, 0x0e)
              else
                self.push(*ldconsts(o)).push(0x0e)
              end
            end

            def %(o)
              if o.is_a? Array
                o.push(*self).push(0xa0, 0x0f)
              else
                self.push(*ldconsts(o)).push(0x0f)
              end
            end
          end
        EOC
      end

      @sb
    end

    def compile(code)
      [*sb.eval(code)]
    end
  end
end
