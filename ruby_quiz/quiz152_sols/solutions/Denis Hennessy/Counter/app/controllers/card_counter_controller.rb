require 'card_counter'

class CardCounterController < ApplicationController

  def practice
    session[:counter] = Counter.new params[:decks].to_i
    session[:min] = params[:min].to_i
    session[:max] = params[:max].to_i
    session[:delay] = params[:delay].to_i
  end

  def deal
    min = session[:min]
    max = session[:max]
    counter = session[:counter]
    max = counter.size if counter.size<max
    min = max if max < min
    count = min + rand(max-min+1)
    text = ""
    text = "Shoe complete" if count == 0
    count.times do
      card = session[:counter].deal
      text += "<img src='/images/#{card_index(card)}.png' width='72' height='96'/>\n"
    end
    text += "<p id='count' style='visibility: hidden'>Count is #{counter.count}</p>"
    render :text => text
  end

  # Convert card name ("6d", "Qs"...) to image index where 1=Ac,2=As,3=Ah,4=Ad,5=Kc and so on
  def card_index(card)
    c = CARDS.index card[0,1].to_s
    s = SUITS.index card[1,1].to_s
    c * 4 + s + 1
  end
end
