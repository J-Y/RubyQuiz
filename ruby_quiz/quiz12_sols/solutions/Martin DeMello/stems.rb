$stems = {}
$seen = {}
$cutoff = ARGV[0].to_i

IO.foreach("sowpods.txt") {|word|
  next if word.length != 8
  word.chomp!
  letters = word.split(//).sort
  alpha = letters.join
  next if $seen[alpha]
  $seen[alpha] = true
  remove = letters.uniq
  remove.each {|i|
    stem = alpha.sub(i, '')
    $stems[stem] ||= {}
    $stems[stem][i] = true
  }
}

$stem_length = {}
$stems.each {|k,v| $stems[k] = v.keys.sort}
$stems.reject! {|k,v| 
  n = v.length
  $stem_length[k] = n
  n < $cutoff
} 

results = $stems.keys.sort_by {|i| -$stem_length[i]}
results.each {|s| p [s, $stem_length[s], $stems[s].join]}
