require 'object_browser'
module ObjectBrowser
  module UI
    # Possible description types, that should be supported by descendants
    DescriptionTypes = [:h1, :h2, :h3, :variable, :method, :module, :class, :object, :other]
    
    # Raised if description factory is not implemented correctly
    class EAbstractError < RuntimeError; end
    
    # Abstract base class for description factories
    class DescriptionFactory
      def add(type, text, object = nil, additional = '')
        raise EAbstractError, 'Method should be implemented'
      end
      
      def add_section(type, text)
        raise EAbstractError, 'Method should be implemented'
      end
    end

    extend self
  end
end
