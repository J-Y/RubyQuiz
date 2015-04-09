require 'rubygems'
require 'text'

include Text::Metaphone
include Text::Levenshtein


expectations = {
    %w[e scent shells] => 'essentials',
    %w[q all if i] => 'qualify',
    %w[fan task tick] => 'fantastic',
    %w[b you tea full] => 'beautiful',
    %w[fun duh mint all] => 'fundamental',
    %w[s cape] => 'escape',
    %w[pan z] => 'pansy',
    %w[n gauge] => 'engage',
    %w[cap tin] => 'captain',
    %w[g rate full] => 'grateful',
    %w[re late shun ship] => 'relationship',
    %w[con grad yeul 8] => 'congratulate',
    %w[2 burr q low sis] => 'tuberculosis',
    %w[my crows cope] => 'microscope',
    %w[add minus ray shun] => 'administration',
    %w[accent you ate it] => 'accentuated',
    %w[add van sing] => 'advancing',
    %w[car knee for us] => 'carnivorous',
    %w[soup or seed] => 'supercede',
    %w[poor 2 bell o] => 'portobello',
    %w[d pen dance] => 'dependence',
    %w[s o tear rick] => 'esoteric',
    %w[4 2 it us] => 'fortuitous',
    %w[4 2 n 8] => 'fortunate',
    %w[4 in R] => 'foreigner',
    %w[naan disk clothes your] => 'nondisclosure',
    %w[Granmda Atika Lee] => 'grammatically',
    %w[a brie vie a shun] => 'abbreviation',
    %w[pheemeeneeneetee] => 'femininity',
    %w[me c c p] => 'mississippi',
    %w[art fork] => 'aardvark',
    %w[liberty giblet] => 'flibbertigibbet',
    %w[zoo key knee] => 'zucchini',
    %w[you'll tight] => 'yuletide',
    %w[Luke I like] => 'lookalike',
    %w[mah deux mah zeal] => 'mademoiselle',
    %w[may gel omen yak] => 'megalomaniac',
    %w[half tell mall eau gist] => 'ophthalmologist',
    %w[whore tea cull your wrist] => 'horticulturist',
    %w[pant oh my m] => 'pantomime',
    %w[tear a ball] => 'terrible',
    %w[a bowl i shun] => 'abolition',
    %w[pre chair] => 'preacher',
    %w[10 s] => 'tennis',
    %w[e z] => 'easy',
    %w[1 door full] => 'wonderful',
    %w[a door] => 'adore',
    %w[hole e] => 'holy',
    %w[grand your] => 'grandeur',
    %w[4 2 5] => 'fortify',
    %w[age, it ate her] => 'agitator',
    %w[tear it or eel] => 'territorial',
    %w[s 1] => 'swan'
}

subs={'1'=>'won','2'=>'to','3'=>'tre','4'=>'for','5'=>'five','6'=>'six','7'=>'seven','8'=>'ate','9'=>'nine','10'=>'ten',
      'h'=>'eich','j'=>'jey','k'=>'key','q'=>'que','r'=>'ar'}
subsy={}
%w[b c d g p t v z].each {|l| subsy[l]=l+'y'}
%w[b c d g p t v z].each {|l| subs[l]=l+'e'}
%w[f l m n s x].each{|l| subs[l]='e'+l}

def metadist(str1,str2)
  2*distance(metaphone(str1),metaphone(str2))+distance(str1,str2)
end

hash=Hash.new{|h,k|h[k]=[]}

File.open("/usr/share/dict/words") {|f| f.readlines}.each do |w|
  word=w.downcase.delete("^a-z")
  m1,m2=double_metaphone(word)
  hash[m1]<<word
  hash[m2]<<word if m2
end
#make sure that expectations are in the word list
expectations.values.each { |word|
  m1,m2=double_metaphone(word)
  hash[m1]<<word
  hash[m2]<<word if m2
}

inputs=[]
if (ARGV.empty?)
  inputs=expectations.keys
else
  inputs << ARGV
end
inputs.each { |rebus|
  y_ed=rebus[0..-2]<<(subsy[rebus[-1]] || rebus[-1])
  word=y_ed.map{|w| subs[w] || w }.join.downcase.gsub(/[^a-z0-9]/,'')
  m1,m2=double_metaphone(word)
  results=hash[m1]
  results+=hash[m2] if m2
  res=results.uniq.sort{|a,b|
    (metadist(word,a) <=> metadist(word,b)).nonzero? || a.length<=>b.length
  }[0] || 'no clue'
  print "'#{rebus.join(' ')}' => #{res}"
  expected=expectations[rebus]
  print ", expected: #{expected}" if expected
  puts
}
