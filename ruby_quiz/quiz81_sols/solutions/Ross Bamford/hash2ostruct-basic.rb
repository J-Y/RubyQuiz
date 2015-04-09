require 'ostruct'

class Hash
  # Convert this hash to a tree of nested OpenStructs (or equivalent class
  # if specified - see DumbStruct). This is the first version I wrote, and
  # it doesn't take account of the evil stuff Mentalguy demo'd, or of illegal
  # method name keys as Adam Shelly pointed out. It's a simple recursive
  # solution, and very inefficient.
  def to_ostruct(clz = OpenStruct)
    clz.new Hash[*inject([]){|ar,(k,v)|ar<< k<<(v.to_ostruct(clz) rescue v)}]
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
  end

  if ARGV.delete('--bm')
    puts "#### Basic impl - OpenStruct ####"
    Benchmark.bm do |x|
      x.report('base  ') { 5000.times { TestHashToOstruct::TD1.to_ostruct } }
      x.report('ara   ') { 5000.times { TestHashToOstruct::TD2.to_ostruct } }
    end

    puts "\n#### Basic impl - DumbStruct ####"
    d = DumbStruct
    Benchmark.bm do |x|
      x.report('base  ') { 5000.times {TestHashToOstruct::TD1.to_ostruct(d)}}
      x.report('ara   ') { 5000.times {TestHashToOstruct::TD2.to_ostruct(d)}}
    end

    puts "\n####   tests   ####"
  end
end

