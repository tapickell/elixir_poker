# given a set of 5 cards match to a type of win or invalid card set
# there can be no duplicate cards
# cards are a `2d` format should parse to a {face, suit} tuple to pattern match
# maybe pass through from top to bottom and kickout on a win ??

# possible faces 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K, A
# possible suits spades, hearts, clubs, diamonds

defmodule Cards do

  def check_hand(cards) do
    with {:no_match, cards} <- invalid(cards),
         {:match, match_type} <- match_hand(cards),
         do: {:ok, match_type}
  end

  defp match_hand(cards) do
    with {:no_match, cards} <- straight_flush(cards),
         {:no_match, cards} <- four_of_a_kind(cards),
         {:no_match, cards} <- full_house(cards),
         {:no_match, cards} <- flush(cards),
         {:no_match, cards} <- straight(cards),
         {:no_match, cards} <- three_of_a_kind(cards),
         {:no_match, cards} <- two_pair(cards),
         {:no_match, cards} <- one_pair(cards),
      do: high_card(cards)
  end

  defp invalid(cards) do
    if no_dups?(cards), do: {:no_match, cards}, else: :invalid
  end

  defp straight_flush(cards) do
    with {:match, :straight} <- straight(cards),
         {:match, :flush} <- flush(cards),
         do: {:match, :straight_flush}
  end

  defp four_of_a_kind(cards) do
    test_for_pairs(cards, [1, 4], :four_of_a_kind)
  end

  defp full_house(cards) do
    test_for_pairs(cards, [2, 3], :full_house)
  end

  defp flush([{_,s}, {_,s}, {_,s}, {_,s}, {_,s}]), do: {:match, :flush}
  defp flush(cards), do: {:no_match, cards}

  defp straight(cards) do
    [hd | tail] = sorted_faces(cards)
    match = matches_on_sequence(hd)
    if match === [hd | tail], do: {:match, :straight}, else: {:no_match, cards}
  end

  defp three_of_a_kind(cards) do
    test_for_pairs(cards, [1, 1, 3], :three_of_a_kind)
  end

  defp two_pair(cards) do
    test_for_pairs(cards, [1, 2, 2], :two_pair)
  end

  defp one_pair(cards) do
    test_for_pairs(cards, [1, 1, 1, 2], :one_pair)
  end

  defp high_card(cards) do
    {:match, :high_card}
  end

  defp test_for_pairs(cards, sequence, symbol) do
    case map_to_pairs(cards) do
      ^sequence ->
        {:match, symbol}
      _ ->
        {:no_match, cards}
    end
  end

  defp map_to_pairs(cards) do
    cards
    |> Enum.map(&face_extract/1)
    |> Enum.group_by(fn(i) -> i end)
    |> Map.values
    |> Enum.map(&Enum.count/1)
    |> Enum.sort
  end

  defp sorted_faces(cards) do
    cards
    |> List.keysort(0)
    |> Enum.map(&face_extract/1)
  end

  defp matches_on_sequence(test) do
    test
    |> sequence_range
    |> sequence_match
  end

  defp no_dups?(cards) do
    Enum.count(Enum.dedup(cards)) === Enum.count(cards)
  end

  defp sequence_range(test) do
    begining = Enum.find_index(Cards.face_sequence(), fn(f) -> f === test end)
    ending = begining + 4
    begining..ending
  end

  defp sequence_match(range) do
    Enum.slice(Cards.face_sequence(), range)
  end

  def face_sequence(), do: [2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K", "A"]

  defp face_extract({face, suit}), do: face
  defp suit_extract({face, suit}), do: suit

  def test_hands() do
    %{
      :invalid => [{2, :spades}, {2, :spades}, {3, :hearts}, {5, :diamonds}, {9, :clubs}],
      :straight_flush => [{"J", :clubs}, {10, :clubs}, {9, :clubs}, {8, :clubs}, {7, :clubs}],
      :four_of_a_kind => [{5, :hearts}, {5, :spades}, {5, :clubs}, {5, :diamonds}, {2, :hearts}],
      :full_house => [{6, :hearts}, {6, :spades}, {6, :clubs}, {2, :hearts}, {2, :clubs}],
      :flush => [{2, :hearts}, {4, :hearts}, {6, :hearts}, {8, :hearts}, {10, :hearts}],
      :straight => [{2, :hearts}, {3, :clubs}, {4, :diamonds}, {5, :clubs}, {6, :hearts}],
      :three_of_a_kind => [{3, :hearts}, {3, :clubs}, {3, :diamonds}, {5, :hearts}, {7, :spades}],
      :two_pair => [{3, :hearts}, {3, :clubs}, {5, :spades}, {5, :clubs}, {9, :hearts}],
      :one_pair => [{3, :hearts}, {3, :clubs}, {4, :clubs}, {8, :hearts}, {7, :spades}],
      :high_card => [{3, :hearts}, {"J", :clubs}, {4, :clubs}, {8, :hearts}, {7, :spades}]
    }
  end
end
