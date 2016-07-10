defmodule Zmobies.Map do
  alias Zmobies.Map, as: Map
  alias Zmobies.Being, as: Being

  defstruct bottom_boundary: 10, right_boundary: 10, beings: []

  def new, do: %Map{}

  def new(bottom_boundary, right_boundary) do
    %Map{bottom_boundary: bottom_boundary, right_boundary: right_boundary}
  end

  def add(map,being) do
    %{
      right_boundary: right_boundary,
      bottom_boundary: bottom_boundary,
      beings: beings
    } = map

    cond do
      being.col_index < 1 ->
        {:error, "#{being} is out of bounds to the left"}
      being.col_index > right_boundary ->
        {:error, "#{being} is out of bounds to the right"}
      being.row_index < 1 ->
        {:error, "#{being} is out of bounds to the north"}
      being.row_index > bottom_boundary ->
        {:error, "#{being} is out of bounds to the south"}
      Enum.any?(beings, Being.on_top_of?(being)) ->
        {:error, "#{being} is trying to place on an occupied space."}
      true ->
        new_map = %{map | beings: map.beings ++ [being]}
        {:ok, new_map}
    end
  end

  def add(map) do
    %{right_boundary: right_boundary, bottom_boundary: bottom_boundary} = map

    being = Being.new(
      col: :random.uniform(right_boundary),
      row: :random.uniform(bottom_boundary)
    )

    add(map, being)
  end
end

defimpl String.Chars, for: Zmobies.Map do
  # necessary for IO.puts
  def to_string(%Zmobies.Map{bottom_boundary: bottom_boundary, right_boundary: right_boundary, beings: beings}) do
    1..bottom_boundary
      |> Enum.to_list
      |> Enum.map(fn(row_index) -> print_row(right_boundary, beings, row_index) end)
      |> Enum.join("\n")
  end

  defp print_row(boundary, beings, row_index) do
    1..boundary
      |> Enum.to_list
      |> Enum.map(fn(col_index) -> print_cell(row_index, col_index, beings) end)
      |> Enum.join(" ")
  end

  defp print_cell(row_index, col_index, beings) do
    maybe_being = Enum.find(
      beings,
      fn(being) -> being.col_index == col_index and being.row_index == row_index end
    )

    case maybe_being do
      %Zmobies.Being{} -> "#{IO.ANSI.red()}X"
      _ -> "#{IO.ANSI.cyan()}O"
    end
  end
end
