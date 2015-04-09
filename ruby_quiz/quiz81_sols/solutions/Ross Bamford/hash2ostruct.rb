require 'ostruct'

class Hash
  # Convert this hash to a tree of nested OpenStructs (or equivalent class
  # if specified - see DumbStruct). This version passes all the test-cases
  # supplied on the ML, though it does need to be used with DumbStruct in 
  # order to pass the test Ara posted, and I chose to fail fast in the 
  # case of illegal method names in the hash keys. It's another recursive 
  # solution, and though it's a bit quicker than the first one, it's still
  # no speed demon.
  def to_ostruct(clz = OpenStruct, cch = {})
    cch[self] = (os = clz.new)
    each do |k,v| 
      raise "Invalid key: #{k}" unless k =~ /[a-z_][a-zA-Z0-9_]*/      
      os.__send__("#{k}=", v.is_a?(Hash)? cch[v] || v.to_ostruct(clz,cch) : v)
    end
    os
  end
end

if $0 == __FILE__
  require 'yaml'
  require 'test/unit'
  require 'benchmark'
  require 'dstruct'
  
  class TestHashToOstruct < Test::Unit::TestCase
    TD1 = YAML::load(%{
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
        a: {x: 1, y: 2, z: 3}
    })

    TD2 = YAML::load(%{
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
        a: {x: 1, y: 2, z: 3}
      table: walnut
      method: linseed oil
      type: contemporary
      id: 1234
      send: fedex
    })

    TD3 = YAML::load(%{
      ---
      &verily
      lemurs:
        unite: *verily
        beneath:
          - patagonian
          - bread
          - products
      thusly: [1, 2, 3, 4]
    })
     
    TD4 = YAML::load(%{
      ---
      1: for the money
      2: for the show
      3: to get ready
      4: go go go
    })
                     
    def test_01
      os = TD1.to_ostruct
     
      assert_equal 1, os.foo
      
      assert_equal [1,2,3], os.bar.baz
      assert_equal ['William Hartnell', 'Patrick Troughton', 'Jon Pertwee',
                    'Tom Baker', 'Peter Davison', 'Colin Baker', 
                    'Sylvester McCoy', 'Paul McGann', 'Christopher Eccleston',
                    'David Tennant'], os.bar.doctors

      assert_equal 1, os.bar.a.x
      assert_equal 2, os.bar.a.y
      assert_equal 3, os.bar.a.z
    end

    def test_02 # ara - need to use DumbStruct to pass this one
      os = TD2.to_ostruct(DumbStruct)
     
      assert_equal 1, os.foo
      
      assert_equal [1,2,3], os.bar.baz
      assert_equal ['William Hartnell', 'Patrick Troughton', 'Jon Pertwee',
                    'Tom Baker', 'Peter Davison', 'Colin Baker', 
                    'Sylvester McCoy', 'Paul McGann', 'Christopher Eccleston',
                    'David Tennant'], os.bar.doctors
      
      assert_equal 1, os.bar.a.x
      assert_equal 2, os.bar.a.y
      assert_equal 3, os.bar.a.z
      
      assert_equal 'walnut', os.table
      assert_equal 'linseed oil', os.method
      assert_equal 'contemporary', os.type
      assert_equal 1234, os.id
      assert_equal 'fedex', os.send
    end

    def test_03 # mental
      os = TD3.to_ostruct

      assert_equal OpenStruct, os.lemurs.unite.lemurs.unite.lemurs.class
      assert_same os.lemurs, os.lemurs.unite.lemurs
      assert_equal ['patagonian', 'bread', 'products'], os.lemurs.beneath
      assert_same os.lemurs.beneath, os.lemurs.unite.lemurs.beneath
      assert_equal [1,2,3,4], os.thusly
      assert_same os.thusly, os.lemurs.unite.thusly
    end

    def test_04 # adam shelly
      assert_raise(RuntimeError) do
        os = TD4.to_ostruct
      end
    end
  end
  
  if ARGV.delete('--bm')
    puts "#### Better impl - OpenStruct ####"
    Benchmark.bm do |x|
      x.report('base  ') { 5000.times { TestHashToOstruct::TD1.to_ostruct } }
      x.report('ara   ') { 5000.times { TestHashToOstruct::TD2.to_ostruct } }
      x.report('mental') { 5000.times { TestHashToOstruct::TD3.to_ostruct } }
    end

    puts "\n#### Better impl - DumbStruct ####"
    d = DumbStruct
    Benchmark.bm do |x|
      x.report('base  ') { 5000.times {TestHashToOstruct::TD1.to_ostruct(d)}}
      x.report('ara   ') { 5000.times {TestHashToOstruct::TD2.to_ostruct(d)}}
      x.report('mental') { 5000.times {TestHashToOstruct::TD3.to_ostruct(d)}}
    end

    puts "\n####   tests   ####"
  end
end

