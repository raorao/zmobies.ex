defmodule Zmobies.Being do
  alias Zmobies.Being, as: Being
  defstruct row_index: nil, col_index: nil, type: nil, pid: nil

  def new(col: col_index, row: row_index, type: type) do
    %Being{col_index: col_index, row_index: row_index, type: type}
  end

  def move_randomly(being) do
    alteration = random_direction

    case :random.uniform(2) do
      1 -> %{being | row_index: being.row_index + alteration }
      2 -> %{being | col_index: being.col_index + alteration }
    end
  end

  def random_direction do
    case :random.uniform(2) do
      1 -> -1
      2 -> 1
    end
  end

  def move_away(being, enemy) do
    case :random.uniform(2) do
      1 ->
        alteration = cond do
         being.row_index > enemy.row_index  -> 1
         being.row_index < enemy.row_index  -> -1
         being.row_index == enemy.row_index -> random_direction
       end
        %{being | row_index: being.row_index + alteration }
      2 ->
        alteration = cond do
          being.col_index > enemy.col_index  -> 1
          being.col_index < enemy.col_index  -> -1
          being.col_index == enemy.col_index -> random_direction
        end
        %{being | col_index: being.col_index + alteration }
    end
  end

  def move_towards(being, enemy) do
    case :random.uniform(2) do
      1 ->
        alteration = cond do
         being.row_index > enemy.row_index  -> -1
         being.row_index < enemy.row_index  -> 1
         being.row_index == enemy.row_index -> 0
       end
        %{being | row_index: being.row_index + alteration }
      2 ->
        alteration = cond do
          being.col_index > enemy.col_index  -> -1
          being.col_index < enemy.col_index  -> 1
          being.col_index == enemy.col_index -> 0
        end
        %{being | col_index: being.col_index + alteration }
    end
  end

  def same_location?(being) do
    fn(other) -> being.col_index == other.col_index && being.row_index == other.row_index end
  end

  def same_type?(being) do
    fn(other) -> being.type == other.type end
  end

  def can_see?(being, other) do
    sight_distance(being) >= distance_from(being, other)
  end

  def starved?(%Zmobies.Being{type: type}, lifetime) do
    case type do
      :zombie -> lifetime > 40
      :human -> false
    end
  end

  def sight_distance(%Zmobies.Being{type: type}) do
    case type do
      :zombie -> 3
      :human -> 5
    end
  end

  def distance_from(being) do
    fn(other) ->
      col_diff = abs(being.col_index - other.col_index)
      row_diff = abs(being.row_index - other.row_index)
      col_diff + row_diff
    end
  end

  def distance_from(being, other) do
    distance_from(being).(other)
  end

  def base_speed(%Zmobies.Being{type: type}) do
    # in milliseconds.
    case type do
      :zombie -> 1000
      :human -> 500
    end
  end
end

defimpl String.Chars, for: Zmobies.Being do
  def to_string(%Zmobies.Being{row_index: row_index, col_index: col_index, type: type}) do
    "#{type_to_string(type)} at location row: #{row_index}, column: #{col_index}"
  end

  defp type_to_string(type) do
    case type do
      :zombie -> 'Zombie'
      :human  -> 'Human'
    end
  end
end
