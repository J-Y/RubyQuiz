order = {
    "Spades"   => "JsJcAsKsQsTs9sAdKdQdJdTd9dAcKcQcTc9cAhKhQhJhTh9h",
    "Hearts"   => "JhJdAhKhQhTh9hAsKsQsJsTs9sAdKdQdTd9dAcKcQcJcTc9c",
    "Clubs"    => "JcJsAcKcQcTc9cAhKhQhJhTh9hAsKsQsTs9sAdKdQdJdTd9d",
    "Diamonds" => "JdJhAdKdQdTd9dAcKcQcJcTc9cAhKhQhTh9hAsKsQsJsTs9s"
}

trump = gets.strip
cards = readlines.map { |l| l.strip }
o = order[trump].dup
# do we have a card of the 2nd suit
unless cards.any? { |card| card[1] == o[15] }
    # if not replace second suit by the last
    o[14, 12] = o[36, 12]
end
puts trump, cards.sort_by { |card| o.index(card) }
