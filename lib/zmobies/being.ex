defmodule Zmobies.Being do
  alias Zmobies.Being, as: Being
  defstruct row_index: nil, col_index: nil

  def new(col: col_index, row: row_index) do
    %Being{col_index: col_index, row_index: row_index}
  end

  def move_randomly(%Being{row_index: row, col_index: col}) do
    alteration = case :random.uniform(2) do
      1 -> -1
      2 -> 1
    end

    case :random.uniform(2) do
      1 -> Being.new(col: col, row: row + alteration)
      2 -> Being.new(col: col + alteration, row: row)
    end
  end

  def same_location?(being) do
    fn(other) -> being.col_index == other.col_index && being.row_index == other.row_index end
  end
end

defimpl String.Chars, for: Zmobies.Being do
  def to_string(%Zmobies.Being{row_index: row_index, col_index: col_index}) do
    "Being at location row: #{row_index}, column: #{col_index}"
  end
end
