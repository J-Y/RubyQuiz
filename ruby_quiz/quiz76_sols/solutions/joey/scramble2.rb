puts 
$<.inject([]){|a,w|a<<w.gsub(/\B(\w+)\B/){$1.split('').sort_by{rand}}}
