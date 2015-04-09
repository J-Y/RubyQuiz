require 'test/unit'

require 'tshirt'

$DEBUG = true

class TestTshirt < Test::Unit::TestCase
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

  positions = []
  expectations.each do |words, expected|
    define_method("test_word_#{expected}") do
      matches = TShirtReader.read(words)

      assert matches.include?(expected)

      positions << matches.index(expected)
      puts "#{expected} @ position #{matches.index(expected)}"
    end
  end
end