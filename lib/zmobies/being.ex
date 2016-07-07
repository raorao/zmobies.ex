defmodule Zmobies.Being do
  defstruct row_index: nil, col_index: nil

  def new(col: col_index, row: row_index) do
    %Zmobies.Being{col_index: col_index, row_index: row_index}
  end
end

defimpl String.Chars, for: Zmobies.Being do
  def to_string(%Zmobies.Being{row_index: row_index, col_index: col_index}) do
    "Being at location row: #{row_index}, column: #{col_index}"
  end
end
