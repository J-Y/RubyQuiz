require 'CSPRuntime'
require 'test/unit'
require 'sodoku'
require 'mastermind'

class CSPTest < Test::Unit::TestCase
  def test_australia_coloring_csp
    clear
    variables [:WA,[:RED,:GREEN,:BLUE]],[:SA,[:RED,:GREEN,:BLUE]],[:NT,[:RED,:GREEN,:BLUE]],[:Q,[:RED,:GREEN,:BLUE]],[:NSW,[:RED,:GREEN,:BLUE]],[:V,[:RED,:GREEN,:BLUE]],[:T,[:RED,:GREEN,:BLUE]]
    constraint $WA =~ $SA
    constraint $WA =~ $NT
    constraint $NT =~ $SA
    func_constraint [:NT,:Q,:SA], lambda{|nt,q,sa| nt != q && nt != sa && q != sa}
    constraint $Q =~ $NSW
    all_diff_constraint :NSW, :V, :SA
    answer = solve
    print "\n",answer.inspect,"\n"
    assert answer
    assert answer[:WA] != answer[:SA] && answer[:WA] != answer[:NT] && answer[:NT] != answer[:SA] && answer[:NT] != answer[:Q] && answer[:Q] != answer[:SA] && answer[:Q] != answer[:NSW] && answer[:NSW] != answer[:SA] && answer[:NSW] != answer[:V] && answer[:V] != answer[:SA]
  end

  def test_cryptarithmetic_with_chain_rules_csp
    clear
    variables [:F,(0 .. 9)],[:T, (0 .. 9)],[:W, (0 .. 9)],[:O,(0..9)],[:U,(0..9)],[:R,(0..9)], [:X1, (0 .. 1)],[:X2, (0 .. 1)],[:X3,(0..1)]
    create_ruleset :rules
    add_rule :rules, [:O], lambda{|known, unknown| o = known[:O];  ret_val = {}; ret_val[:R] = unknown[:R].intersection([(o*2)%10]); ret_val[:X1] = unknown[:X1].intersection([(o*2/10).floor]);ret_val}
    add_rule :rules, [:R], lambda{|known, unknown| r = known[:R]; ret_val = {}; ret_val[:O] = unknown[:O].intersection([(r/2).floor,((r+10)/2).floor]);ret_val}
    add_rule :rules, [:X1], lambda{|known, unknown| x1 = known[:X1]; ret_val = {}; ret_val[:O] = unknown[:O].find_all{|val| val*2 >= x1 * 10 && val*2 < x1*10+10}.to_set; ret_val[:R] = unknown[:R].find_all{|val| val % 2 == 0}.to_set; ret_val}
    add_chain_rule :rules, [:O, :R], [:O]
    add_chain_rule :rules, [:O, :X1], [:O]
    add_chain_rule :rules, [:R, :X1], [:R], [:X1]
    constraint $O + $O == $R + $X1 * 10,:rules
    create_ruleset :x1wwux2
    add_rule :x1wwux2, [:W], 
      lambda{|known, unknown| 
        w= known[:W]
        ret_val = {}
        ret_val[:U] = unknown[:U].intersection([w*2,w*2+1])
        ret_val[:X2] = unknown[:X2].intersection([(w/5).floor])
        return ret_val
      }
    add_rule :x1wwux2, [:U], 
      lambda{|known, unknown|
        u = known[:U]
        ret_val = {}
        ret_val[:X1] = unknown[:X1].intersection([u%2])
        ret_val[:W] = unknown[:W].intersection([(u/2).floor,((u+10)/2).floor])
        return ret_val
      }
    add_rule :x1wwux2, [:X2], 
      lambda{|known, unknown|
        x2 = known[:X2]
        ret_val = {}
        ret_val[:W] = unknown[:W].find_all{|val| (val >= 5 && x2 > 0) || (val < 5 && x2 == 0)}.to_set
        return ret_val
      }
    add_rule :x1wwux2, [:X1], 
      lambda{|known, unknown|
        x1 = known[:X1]
        ret_val = {}
        ret_val[:U] = unknown[:U].find_all{|val| val % 2 == x1}.to_set
        return ret_val
      }
    add_chain_rule :x1wwux2, [:X1, :W], [:X1], [:W]
    add_chain_rule :x1wwux2, [:U, :X2], [:U], [:X2]
    add_chain_rule :x1wwux2, [:X1, :X2], [:X1], [:X2]
    add_chain_rule :x1wwux2, [:W, :X2], [:W]
    add_chain_rule :x1wwux2, [:X1, :U], [:U]
    add_chain_rule :x1wwux2, [:W, :U], [:W], [:U]
    add_chain_rule :x1wwux2, [:X1, :W, :U], [:W]
    add_chain_rule :x1wwux2, [:U, :X2, :W], [:U]
    add_chain_rule :x1wwux2, [:X1, :X2, :U], [:U, :X2]
    add_chain_rule :x1wwux2, [:W, :X2, :X1], [:X1, :W]
    constraint $X1 + $W + $W == $U + $X2 * 10, :x1wwux2
    create_ruleset :x2wwux3
    add_rule :x2wwux3, [:T], 
      lambda{|known, unknown| 
        w= known[:T]
        ret_val = {}
        ret_val[:O] = unknown[:O].intersection([w*2,w*2+1])
        ret_val[:X3] = unknown[:X3].intersection([(w/5).floor])
        return ret_val
      }
    add_rule :x2wwux3, [:O], 
      lambda{|known, unknown|
        u = known[:O]
        ret_val = {}
        ret_val[:X2] = unknown[:X2].intersection([u%2])
        ret_val[:T] = unknown[:T].intersection([(u/2).floor,((u+10)/2).floor])
        return ret_val
      }
    add_rule :x2wwux3, [:X3], 
      lambda{|known, unknown|
        x3 = known[:X3]
        ret_val = {}
        ret_val[:T] = unknown[:T].find_all{|val| (val >= 5 && x3 > 0) || (val < 5 && x3 == 0)}.to_set
        return ret_val
      }
    add_rule :x2wwux3, [:X2], 
      lambda{|known, unknown|
        x2 = known[:X2]
        ret_val = {}
        ret_val[:O] = unknown[:O].find_all{|val| val % 2 == x2}.to_set
        return ret_val
      }
    add_chain_rule :x2wwux3, [:X2, :T], [:X2], [:T]
    add_chain_rule :x2wwux3, [:O, :X3], [:O], [:X3]
    add_chain_rule :x2wwux3, [:X2, :X3], [:X2], [:X3]
    add_chain_rule :x2wwux3, [:T, :X3], [:T]
    add_chain_rule :x2wwux3, [:X2, :O], [:O]
    add_chain_rule :x2wwux3, [:T, :O], [:T], [:O]
    add_chain_rule :x2wwux3, [:X2, :T, :O], [:T]
    add_chain_rule :x2wwux3, [:O, :X3, :T], [:O]
    add_chain_rule :x2wwux3, [:X2, :X3, :O], [:O, :X3]
    add_chain_rule :x2wwux3, [:T, :X3, :X2], [:X2, :T]
    constraint $X2 + $T + $T == $O + $X3 * 10, :x2wwux3
    constraint $X3 == $F
    constraint $F =~ 0
    constraint $T =~ 0
    all_diff_constraint :F,:T,:W,:O,:U,:R
    #debug
    #print_csp
    answer = solve
    print "\n",answer.inspect,"\n"
    assert answer
    assert answer[:O] * 2 == answer[:R] + 10 * answer[:X1] && answer[:X1] + answer[:W] * 2 == answer[:U] + 10 * answer[:X2] && answer[:X2] + answer[:T] * 2 == answer[:O] + 10 * answer[:X3] && answer[:F] == answer[:X3] && answer[:F] != 0 && answer[:T] != 0  
  end

  def test_cryptarithmetic_csp
    clear
    variables [:F,(0 .. 9)],[:T, (0 .. 9)],[:W, (0 .. 9)],[:O,(0..9)],[:U,(0..9)],[:R,(0..9)], [:X1, (0 .. 1)],[:X2, (0 .. 1)],[:X3,(0..1)]
    create_ruleset :rules
    add_rule :rules, [:O], lambda{|known, unknown| o = known[:O];  ret_val = {}; ret_val[:R] = unknown[:R].intersection([(o*2)%10]); ret_val[:X1] = unknown[:X1].intersection([(o*2/10).floor]);ret_val}
    add_rule :rules, [:R], lambda{|known, unknown| r = known[:R]; ret_val = {}; ret_val[:O] = unknown[:O].intersection([(r/2).floor,((r+10)/2).floor]);ret_val}
    add_rule :rules, [:X1], lambda{|known, unknown| x1 = known[:X1]; ret_val = {}; ret_val[:O] = unknown[:O].find_all{|val| val*2 >= x1 * 10 && val*2 < x1*10+10}.to_set; ret_val[:R] = unknown[:R].find_all{|val| val % 2 == 0}.to_set; ret_val}
    add_rule :rules, [:O, :R], lambda{|known, unknown| o = known[:O];  ret_val = {}; ret_val[:X1] = unknown[:X1].intersection([(o*2/10).floor]);ret_val}
    add_rule :rules, [:O, :X1], lambda{|known, unknown| o = known[:O];  ret_val = {}; ret_val[:R] = unknown[:R].intersection([(o*2)%10]); ret_val}
    add_rule :rules, [:R, :X1], lambda{|known, unknown| r = known[:R]; x1 = known[:X1]; ret_val[:O] = unknown[:O].intersection([r + x1*10]); ret_val}
    constraint $O + $O == $R + $X1 * 10,:rules
    create_ruleset :x1wwux2
    add_rule :x1wwux2, [:W], 
      lambda{|known, unknown| 
        w= known[:W]
        ret_val = {}
        ret_val[:U] = unknown[:U].intersection([w*2,w*2+1])
        ret_val[:X2] = unknown[:X2].intersection([(w/5).floor])
        return ret_val
      }
    add_rule :x1wwux2, [:U], 
      lambda{|known, unknown|
        u = known[:U]
        ret_val = {}
        ret_val[:X1] = unknown[:X1].intersection([u%2])
        ret_val[:W] = unknown[:W].intersection([(u/2).floor,((u+10)/2).floor])
        return ret_val
      }
    add_rule :x1wwux2, [:X2], 
      lambda{|known, unknown|
        x2 = known[:X2]
        ret_val = {}
        ret_val[:W] = unknown[:W].find_all{|val| (val >= 5 && x2 > 0) || (val < 5 && x2 == 0)}.to_set
        return ret_val
      }
    add_rule :x1wwux2, [:X1], 
      lambda{|known, unknown|
        x1 = known[:X1]
        ret_val = {}
        ret_val[:U] = unknown[:U].find_all{|val| val % 2 == x1}.to_set
        return ret_val
      }
    add_rule :x1wwux2, [:X1, :W], 
      lambda{|known, unknown|
        x1 = known[:X1]
        w = known[:W]
        ret_val = {}
        ret_val[:X2] = unknown[:X2].intersection([((x1+2*w)/10).floor])
        ret_val[:U] = unknown[:U].intersection([(x1+2*w)%10])
        return ret_val
      }
    add_rule :x1wwux2, [:U, :X2], 
      lambda{|known, unknown|
        u = known[:U]
        x2 = known[:X2]
        ret_val = {}
        ret_val[:W] = unknown[:W].intersection([((u+10*x2)/2).floor])
        ret_val[:X1] = unknown[:X1].intersection([u%2])
        return ret_val
      }
    add_rule :x1wwux2, [:X1, :X2], 
      lambda{|known, unknown|
        x1 = known[:X1]
        x2 = known[:X2]
        ret_val = {}
        ret_val[:U] = unknown[:U].find_all{|val| val % 2 == x1}.to_set
        ret_val[:W] = unknown[:W].find_all{|val| (val >= 5 && x2 > 0) || (val < 5 && x2 == 0)}.to_set
        return ret_val
      }
    add_rule :x1wwux2, [:W, :X2], 
      lambda{|known, unknown|
        w = known[:W]
        x2 = known[:X2]
        ret_val = {}
        ret_val[:U] = unknown[:U].intersection([w*2,w*2+1])
        return ret_val
      }
    add_rule :x1wwux2, [:X1, :U], 
      lambda{|known, unknown|
        x1 = known[:X1]
        u = known[:U]
        ret_val = {}
        ret_val[:W] = unknown[:W].intersection([(u/2).floor,((u+10)/2).floor])
        return ret_val
      }
    add_rule :x1wwux2, [:W, :U], 
      lambda{|known, unknown|
        w = known[:W]
        u = known[:U]
        ret_val = {}
        ret_val[:X2] = unknown[:X2].intersection([(w/5).floor])
        ret_val[:X1] = unknown[:X1].intersection([u%2])
        return ret_val
      }
    add_rule :x1wwux2, [:X1, :W, :U], 
      lambda{|known, unknown|
        w = known[:W]
        ret_val = {}
        ret_val[:X2] = unknown[:X2].intersection([(w/5).floor])
        return ret_val
      }
    add_rule :x1wwux2, [:U, :X2, :W], 
      lambda{|known, unknown|
        u = known[:U]
        ret_val = {}
        ret_val[:X1] = unknown[:X1].intersection([u%2])
        return ret_val
      }
    add_rule :x1wwux2, [:X1, :X2, :U], 
      lambda{|known, unknown|
        u = known[:U]
        x2 = known[:X2]
        ret_val = {}
        ret_val[:W] = unknown[:W].intersection([((u+10*x2)/2).floor])
        return ret_val
      }
    add_rule :x1wwux2, [:W, :X2, :X1], 
      lambda{|known, unknown|
        x1 = known[:X1]
        w = known[:W]
        ret_val = {}
        ret_val[:U] = unknown[:U].intersection([(x1+2*w)%10])
        return ret_val
      }
    constraint $X1 + $W + $W == $U + $X2 * 10, :x1wwux2
    create_ruleset :x2wwux3
    add_rule :x2wwux3, [:T], 
      lambda{|known, unknown| 
        w= known[:T]
        ret_val = {}
        ret_val[:O] = unknown[:O].intersection([w*2,w*2+1])
        ret_val[:X3] = unknown[:X3].intersection([(w/5).floor])
        return ret_val
      }
    add_rule :x2wwux3, [:O], 
      lambda{|known, unknown|
        u = known[:O]
        ret_val = {}
        ret_val[:X2] = unknown[:X2].intersection([u%2])
        ret_val[:T] = unknown[:T].intersection([(u/2).floor,((u+10)/2).floor])
        return ret_val
      }
    add_rule :x2wwux3, [:X3], 
      lambda{|known, unknown|
        x3 = known[:X3]
        ret_val = {}
        ret_val[:T] = unknown[:T].find_all{|val| (val >= 5 && x3 > 0) || (val < 5 && x3 == 0)}.to_set
        return ret_val
      }
    add_rule :x2wwux3, [:X2], 
      lambda{|known, unknown|
        x2 = known[:X2]
        ret_val = {}
        ret_val[:O] = unknown[:O].find_all{|val| val % 2 == x2}.to_set
        return ret_val
      }
    add_rule :x2wwux3, [:X2, :T], 
      lambda{|known, unknown|
        x2 = known[:X2]
        w = known[:T]
        ret_val = {}
        ret_val[:X3] = unknown[:X3].intersection([((x2+2*w)/10).floor])
        ret_val[:O] = unknown[:O].intersection([(x2+2*w)%10])
        return ret_val
      }
    add_rule :x2wwux3, [:O, :X3], 
      lambda{|known, unknown|
        u = known[:O]
        x3 = known[:X3]
        ret_val = {}
        ret_val[:T] = unknown[:T].intersection([((u+10*x3)/2).floor])
        ret_val[:X2] = unknown[:X2].intersection([u%2])
        return ret_val
      }
    add_rule :x2wwux3, [:X2, :X3], 
      lambda{|known, unknown|
        x2 = known[:X2]
        x3 = known[:X3]
        ret_val = {}
        ret_val[:O] = unknown[:O].find_all{|val| val % 2 == x2}.to_set
        ret_val[:T] = unknown[:T].find_all{|val| (val >= 5 && x3 > 0) || (val < 5 && x3 == 0)}.to_set
        return ret_val
      }
    add_rule :x2wwux3, [:T, :X3], 
      lambda{|known, unknown|
        w = known[:T]
        x3 = known[:X3]
        ret_val = {}
        ret_val[:O] = unknown[:O].intersection([w*2,w*2+1])
        return ret_val
      }
    add_rule :x2wwux3, [:X2, :O], 
      lambda{|known, unknown|
        x2 = known[:X2]
        u = known[:O]
        ret_val = {}
        ret_val[:T] = unknown[:T].intersection([(u/2).floor,((u+10)/2).floor])
        return ret_val
      }
    add_rule :x2wwux3, [:T, :O], 
      lambda{|known, unknown|
        w = known[:T]
        u = known[:O]
        ret_val = {}
        ret_val[:X3] = unknown[:X3].intersection([(w/5).floor])
        ret_val[:X2] = unknown[:X2].intersection([u%2])
        return ret_val
      }
    add_rule :x2wwux3, [:X2, :T, :O], 
      lambda{|known, unknown|
        w = known[:T]
        ret_val = {}
        ret_val[:X3] = unknown[:X3].intersection([(w/5).floor])
        return ret_val
      }
    add_rule :x2wwux3, [:O, :X3, :T], 
      lambda{|known, unknown|
        u = known[:O]
        ret_val = {}
        ret_val[:X2] = unknown[:X2].intersection([u%2])
        return ret_val
      }
    add_rule :x2wwux3, [:X2, :X3, :O], 
      lambda{|known, unknown|
        u = known[:O]
        x3 = known[:X3]
        ret_val = {}
        ret_val[:T] = unknown[:T].intersection([((u+10*x3)/2).floor])
        return ret_val
      }
    add_rule :x2wwux3, [:T, :X3, :X2], 
      lambda{|known, unknown|
        x2 = known[:X2]
        w = known[:T]
        ret_val = {}
        ret_val[:O] = unknown[:O].intersection([(x2+2*w)%10])
        return ret_val
      }
    constraint $X2 + $T + $T == $O + $X3 * 10, :x2wwux3
    constraint $X3 == $F
    constraint $F =~ 0
    constraint $T =~ 0
    all_diff_constraint :F,:T,:W,:O,:U,:R
    #debug
    #print_csp
    answer = solve
    print "\n",answer.inspect,"\n"
    assert answer
    assert answer[:O] * 2 == answer[:R] + 10 * answer[:X1] && answer[:X1] + answer[:W] * 2 == answer[:U] + 10 * answer[:X2] && answer[:X2] + answer[:T] * 2 == answer[:O] + 10 * answer[:X3] && answer[:F] == answer[:X3] && answer[:F] != 0 && answer[:T] != 0
  end
  
  def test_zebra
    clear
    variables [:RED,(1 .. 5)],[:YELLOW,(1..5)],[:BLUE,(1..5)],[:GREEN,(1..5)],[:IVORY,(1..5)],[:ENGLAND,(1..5)],[:SPAIN,(1..5)],[:NORWAY,(1..5)],[:UKRAIN,(1..5)],[:JAPAN,(1..5)],[:DOG,(1..5)],[:ZEBRA,(1..5)],[:SNAIL,(1..5)],[:HORSE,(1..5)],[:FOX,(1..5)],[:TEA,(1..5)],[:MILK,(1..5)],[:OJ,(1..5)],[:COFFEE,(1..5)],[:WATER,(1..5)],[:KOOL,(1..5)],[:LUCKYSTRIKE,(1..5)],[:WINSTON,(1..5)],[:PARLIAMENT,(1..5)],[:CHESTERFIELD,(1..5)]
    all_diff_constraint :RED, :YELLOW, :BLUE, :GREEN, :IVORY
    all_diff_constraint :ENGLAND, :SPAIN, :NORWAY, :UKRAIN, :JAPAN
    all_diff_constraint :DOG, :ZEBRA, :SNAIL, :HORSE, :FOX
    all_diff_constraint :TEA, :MILK, :OJ, :COFFEE, :WATER
    all_diff_constraint :KOOL, :LUCKYSTRIKE, :CHESTERFIELD, :PARLIAMENT, :WINSTON
    constraint $ENGLAND == $RED
    constraint $SPAIN == $DOG
    constraint $NORWAY == 1
    constraint $KOOL == $YELLOW
    create_ruleset :rule
    set_default_rule :rule, lambda{|known, unknown| return {} if known.empty?; val = known.values[0]; ret_val = {}; unknown.each{|key, value|ret_val[key] = value.intersection([val+1,val-1]);};ret_val}
    func_constraint [:CHESTERFIELD, :FOX], lambda{|c,f| (c == f + 1) || (c == f - 1)}, :rule
    func_constraint [:NORWAY, :BLUE], lambda{|n,b| (n == b + 1) || (n == b - 1)}, :rule
    constraint $WINSTON == $SNAIL
    constraint $LUCKYSTRIKE == $OJ
    constraint $UKRAIN == $TEA
    constraint $JAPAN == $PARLIAMENT
    func_constraint [:KOOL, :HORSE], lambda{|k,h| (k == h + 1) || (k == h - 1)}, :rule
    constraint $COFFEE == $GREEN
    create_ruleset :rule
    add_rule :rule, [:GREEN], lambda{|known, unknown| g = known[:GREEN]; return {:IVORY=>(unknown[:IVORY].intersection([g-1]))}}
    add_rule :rule, [:IVORY], lambda{|known, unknown| i = known[:IVORY]; return {:GREEN=>(unknown[:GREEN].intersection([i+1]))}}
    constraint $GREEN == $IVORY + 1,:rule
    constraint $MILK == 3
    #debug
    answer = solve
    assert answer
    print "\n",answer.inspect,"\n"
    print "The zebra lives at house \##{answer[:ZEBRA]} and the water drinker is in house \##{answer[:WATER]}\n";
  end
  
  def test_sodoku #http://www.dailysudoku.co.uk/sudoku/archive/2006/03/2006-03-6.shtml
    s = Sodoku.new(9)
    s.set_known_value(9, [2,2])
    s.set_known_value(3, [2,3])
    s.set_known_value(5, [3,3])
    s.set_known_value(8, [4,2])
    s.set_known_value(6, [6,1])
    s.set_known_value(2, [6,3])
    s.set_known_value(7, [7,1])
    s.set_known_value(9, [7,3])
    s.set_known_value(8, [8,3])
    s.set_known_value(4, [9,2])
    s.set_known_value(2, [2,4])
    s.set_known_value(1, [2,6])
    s.set_known_value(6, [4,4])
    s.set_known_value(2, [4,6])
    s.set_known_value(4, [6,4])
    s.set_known_value(7, [6,6])
    s.set_known_value(1, [8,4])
    s.set_known_value(6, [8,6])
    s.set_known_value(1, [1,8])
    s.set_known_value(6, [2,7])
    s.set_known_value(9, [3,7])
    s.set_known_value(3, [3,9])
    s.set_known_value(3, [4,7])
    s.set_known_value(7, [4,9])
    s.set_known_value(8, [6,8])
    s.set_known_value(8, [7,7])
    s.set_known_value(5, [8,7])
    s.set_known_value(7, [8,8])
    answer = s.solve
    assert answer
    print "\n"
    ("01" .. "09").each do |y|
      ("01" .. "09").each do |x|
        print answer[(x + y).to_sym]," "
      end
      print "\n"
    end
  end
  
  def test_mastermind
    mm = MasterMind.new(6,4)
    mm.code_maker.print_code
    answer = mm.solve
    assert answer
    print "The answer found is ",answer.inspect,"\n"
    assert answer.all?{|key_val| mm.code_maker.code[key_val[0].to_s.to_i - 1] == key_val[1]}
  end
end