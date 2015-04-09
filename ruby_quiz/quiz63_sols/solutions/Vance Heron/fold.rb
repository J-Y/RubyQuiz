#! /usr/bin/env ruby

def fold row_siz, cmds
 # paper is an array of layers,
 # each layer is an array of rows,
 # each row is an array of integers

 paper = []
 layer = []
 1.upto(row_siz){|i|
   row = []
   1.upto(row_siz){|j| row << j + row_siz*(i-1)}
   layer << row
 }
 paper = [ layer ]

 nfold = (Math.log(row_siz)/Math.log(2))   # Number of folds each direction

 # validate inputs
 raise "Array size not a power of 2" unless 2**nfold == row_siz
 raise "Invalid cmd length" unless cmds.length == nfold * 2
 raise "Invalid fold chars"  unless cmds.scan(/[TBLR]/).length == nfold * 2
 raise "Invalid fold list" unless cmds.scan(/[TB]/).length == nfold

 cmds.split(//).each{|f|
   new_paper = []
   case f
   when 'L','R'
     row_siz = paper[0][0].length/2
     s1, s2 = (f == 'L') ? [0,row_siz] : [row_siz,0]
     paper.reverse.each { |layer|
       new_layer = []
       layer.each {|row|
         new_layer << row.slice(s1,row_siz).reverse
       }
       new_paper << new_layer
     }
     paper.each { |layer|
       new_layer = []
       layer.each {|row|
         new_layer << row.slice(s2,row_siz)
       }
       new_paper << new_layer
     }
   when 'T','B'
     col_siz = paper[0].length/2
     s1, s2 = (f == 'T') ? [0,col_siz] : [col_siz,0]
     paper.reverse.each { |layer|
       new_paper << layer.slice(s1,col_siz).reverse
     }
     paper.each { |layer|
       new_paper << layer.slice(s2, col_siz)
     }
   end
   paper = new_paper
 }
 return paper.flatten
end

def usage
 puts "Usage #{File.basename($0)} <grid sz> <fold list>"
 puts "  grid sz must be power of 2"
 puts "  valid fold are T, B, R, L"
 puts "  you must have enough folds to get NxN to 1x1"
 exit
end

usage unless ARGV.length == 2

row_siz = ARGV[0].to_i
cmds = ARGV[1]

res = fold(row_siz, cmds)
puts "RES"
puts "[ #{res.join(', ')} ]"
