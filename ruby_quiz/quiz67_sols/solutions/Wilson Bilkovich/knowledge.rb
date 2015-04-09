# so many paths go up from the foothills
# but one moon grazes the peak

# stare at it until your eyes drop out
# this desk this wall this unreal page

# the edges of the sword are life and death
# no one knows which is which

# inside the koan clear mind
# gashes the great darkness

class Module
  def attribute(name, &block)
    return name.map {|k,v| attribute(k) {v}} if name.is_a?(Hash)
    define_method("__#{name}__", block || proc{nil})
    class_eval <<-ZEN
      attr_writer :#{name}
      def #{name}
        defined?(@#{name}) ? @#{name} : @#{name} = __#{name}__
      end
      def #{name}?
        true unless #{name}.nil?
      end
    ZEN
  end
end

# clouds endless clouds climbing beyond
# ask nothing from words on a page

# lone moon, no clouds
# we stumble through the night

# long life
# the wild pines want it too

# mirror facing a mirror
# nowhere else

# only one koan matters
# you
