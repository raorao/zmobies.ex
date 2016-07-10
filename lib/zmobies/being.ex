defmodule Zmobies.Being do
  alias Zmobies.Being, as: Being
  defstruct row_index: nil, col_index: nil, type: nil

  def new(col: col_index, row: row_index, type: type) do
    %Being{col_index: col_index, row_index: row_index, type: type}
  end

  def move_randomly(being) do
    alteration = case :random.uniform(2) do
      1 -> -1
      2 -> 1
    end

    case :random.uniform(2) do
      1 -> %{being | row_index: being.row_index + alteration }
      2 -> %{being | col_index: being.col_index + alteration  }
    end
  end

  def same_location?(being) do
    fn(other) -> being.col_index == other.col_index && being.row_index == other.row_index end
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
