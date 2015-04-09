
module BasicStrategy
  def strategy(board, side)
    rank = board.score(side) - board.score(1 - side)

    board.pit_range(1 - side).each_with_index do |pit, i|
      rank -= board[board.opposite(pit)] if board[pit].zero? ||
        board[pit] == board.kalah(1 - side) - pit
    end

    if side == board.turn
      rank += possible_score(board, side) - board[board.kalah(1 - side)]
    else
      rank += board[board.kalah(side)] - possible_score(board, 1 - side)
    end

    rank
  end

  def possible_score(board, side = board.turn)
    pits = board.pit_range(side).to_a.reverse
    state = board.dup

    begin
      repeat = false
      pits.each_with_index do |pit, i|
        if state[pit] == 1 + i
          state.sow! pit
          repeat = true
          break
        end
      end
    end while repeat

    pits.each_with_index do |pit, i|
      if state[pit] >= 1 + i
        state.sow! pit
        break
      end
    end

    state[state.kalah(side)]
  end
end
