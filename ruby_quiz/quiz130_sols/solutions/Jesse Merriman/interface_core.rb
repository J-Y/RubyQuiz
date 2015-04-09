module Hangman
  module Interface
    def Interface.looks_ok? possible_iface
      possible_iface.respond_to?(:phrase_pattern) and
        possible_iface.respond_to?(:suggest) and
        possible_iface.respond_to?(:display) and
        possible_iface.respond_to?(:finish)
    end

    class Core; end
  end
end
