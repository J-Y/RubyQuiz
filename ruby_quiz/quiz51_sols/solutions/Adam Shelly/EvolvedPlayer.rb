require 'ads_lc_player'

class EvolvedPlayer < ADS_LC_Player
	def initialize
		super
		load "gene.yaml"
	end

    #fix for bug in ADS_LC_Player where it would draw from a discard
    #right after playing on that suit and making the wanted card useless
    def draw_card
        @dwanted.each_with_index{|w,i|
            if w && (@dpile[i][-1] > (@land[i][-1]||0))
                @dpile[i].pop
                return [S.index(i)].pack("C")
            end
        }
        @deckcount-=1
        "n"
    end

end
