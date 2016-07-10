defmodule Zmobies.Being do
  alias Zmobies.Being, as: Being
  defstruct row_index: nil, col_index: nil

  def new(col: col_index, row: row_index) do
    %Being{col_index: col_index, row_index: row_index}
  end

  def on_top_of?(being) do
    fn(other) -> being.col_index == other.col_index && being.row_index == other.row_index end
  end
end

defimpl String.Chars, for: Zmobies.Being do
  def to_string(%Zmobies.Being{row_index: row_index, col_index: col_index}) do
    "Being at location row: #{row_index}, column: #{col_index}"
  end
end
