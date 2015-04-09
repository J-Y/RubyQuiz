require 'yaml'
require 'ostruct'
class Object
  def hash_to_ostruct(visited = [])
    self
  end
end

class Array
  def hash_to_ostruct(visited = [])
    map { |x| x.hash_to_ostruct(visited) }
  end
end

class Hash
  def hash_to_ostruct(visited = [])
    os = OpenStruct.new
    each do |k, v|
      item = visited.find { |x| x.first.object_id == v.object_id }
      if item
	os.send("#{k}=", item.last)
      else
	os.send("#{k}=", v.hash_to_ostruct(visited + [ [self, os] ]))
      end
    end
    os
  end
end

yaml_source = <<YAML
---
foo: 1
bar:
  baz: [1, 2, 3]
  quux: 42
  doctors:
    - William Hartnell
    - Patrick Troughton
    - Jon Pertwee
    - Tom Baker
    - Peter Davison
    - Colin Baker
    - Sylvester McCoy
    - Paul McGann
    - Christopher Eccleston
    - David Tennant
    - {w: 1, t: 7}
  a: {x: 1, y: 2, z: 3}
YAML
evil_yaml = <<EVIL
---
&verily
lemurs:
  unite: *verily
  beneath:
    - patagonian
    - bread
    - products
thusly: [1, 2, 3, 4]
EVIL

loaded = YAML.load(yaml_source).hash_to_ostruct
p loaded.bar.doctors.last.w

evil_loaded = YAML.load(evil_yaml).hash_to_ostruct
p evil_loaded.lemurs.beneath
p evil_loaded.lemurs.unite.thusly
