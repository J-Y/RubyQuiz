require 'rubygems'
require 'text'
include Text::Metaphone
include Text::Levenshtein
load 'expectations.rb'

subs={'1'=>'won','2'=>'to','3'=>'tre','4'=>'for','5'=>'five','6'=>'six','7'=>'seven','8'=>'ate','9'=>'nine','10'=>'ten',
      'c'=>'see','h'=>'eich','j'=>'jey','k'=>'key','q'=>'que','r'=>'ar'}
subsy={}
%w[b c d g p t v z].each {|l| subsy[l]=l+'y'}
%w[b c d g p t v z].each {|l| subs[l]=l+'ee'}
%w[f l m n s x].each{|l| subs[l]='e'+l}

def metadist(str1,str2)
  2*distance(metaphone(str1),metaphone(str2))+
  distance(str1,str2)
end

words = (File.open("/usr/share/dict/words") {|f| f.readlines}.map{|word| 
word.downcase.delete("^a-z")}+$expectations.values).uniq

inputs=[]
if (ARGV.empty?)
  inputs=$expectations.keys
else
  inputs << ARGV
end

inputs.each { |rebus|
  y_ed=rebus[0..-2]<<(subsy[rebus[-1]] || rebus[-1])
  word=y_ed.map{|w| subs[w] || w }.join.downcase.gsub(/[^a-z0-9]/,'')
  res=words.sort_by{ |a| [metadist(word,a),a.length] }.first(5)
  print "'#{rebus.join(' ')}' => #{res[0]}"
  expected=$expectations[rebus]
  print ", expected '#{expected}' is at position #{res.index(expected)}" if expected
  puts
}
