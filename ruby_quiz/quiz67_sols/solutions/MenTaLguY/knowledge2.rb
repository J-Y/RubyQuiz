class Module
  def attribute( name, &default_block )
    name, default_value = name.to_a.first if name.is_a? Hash
    default_block ||= proc { default_value }

    name = name.to_sym

    define_method( "__default__#{ name }", &default_block )

    define_method( :__attributes__ ) do
      @__attributes__ ||= Hash.new { |h, k| h[k] = send "__default__#{ k }" }
    end

    define_method( name ) { __attributes__[name] }
    define_method( "#{ name }=" ) { |value| __attributes__[name] = value }
    alias_method "#{ name }?", name
  end
end
