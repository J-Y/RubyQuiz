# RubyQuiz81: Hash to OpenStruct
# 2006-06-02

require 'ostruct'
require 'yaml'

class HashToOpenStruct
  def self.from_yaml(yamlfile)
    self.to_ostruct(YAML.load(File.open(yamlfile)))
  end

  def self.to_ostruct(h)
    c = OpenStruct.new
    h.each { |k,v| c.__send__("#{k}=".to_sym,
                              v.kind_of?(Hash) ? to_ostruct(v) : v) }
    c
  end
end
