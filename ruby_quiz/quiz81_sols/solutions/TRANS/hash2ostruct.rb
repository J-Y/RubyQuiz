i = YAML::load(s)
def Hash.def to_yaml_type
  "!ruby/object:OpenStruct"
end
o = YAML::load(i.to_yaml)
