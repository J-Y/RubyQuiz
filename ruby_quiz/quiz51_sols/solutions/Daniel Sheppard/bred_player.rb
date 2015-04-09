require 'rule_player'
require 'yaml'

class BredPlayer < MultiplierPlayer
    def initialize
        raise "No Data File" unless File.exist?('data2.yaml')
        multipliers, rule_names = File.open('data2.yaml','r') { |f| YAML::load(f) } 
        super(rule_names, multipliers[0])
    end
end
    
