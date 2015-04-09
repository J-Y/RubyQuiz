module Trampoline
   # Instance methods
   class Bounce
      def initialize(cons, klass, *args)
         @klass, @cons, @args = klass, cons, args
      end

      def method_missing(method, *args)
         @obj = @klass.send(@cons, *@args) unless @obj
         @obj.send(method, *args)
      end
   end

   # Class methods
   class << Bounce
      alias_method :old_new, :new

      def new(*args)
         old_new(:new, *args)
      end

      def method_missing(method, *args)
         old_new(method, *args)
      end
   end
end
