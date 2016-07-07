defmodule Zmobies.World do
  defstruct bottom_boundary: 10, right_boundary: 10, beings: []

  def new, do: %Zmobies.World{}

  def new(bottom_boundary, right_boundary) do
    %Zmobies.World{bottom_boundary: bottom_boundary, right_boundary: right_boundary}
  end

  def add(world,being) do
    %{
      right_boundary: right_boundary,
      bottom_boundary: bottom_boundary,
      beings: beings
    } = world

    cond do
      being.col_index < 1 ->
        {:error, "#{being} is out of bounds to the left"}
      being.col_index > right_boundary ->
        {:error, "#{being} is out of bounds to the right"}
      being.row_index < 1 ->
        {:error, "#{being} is out of bounds to the north"}
      being.row_index > bottom_boundary ->
        {:error, "#{being} is out of bounds to the south"}
      Enum.any?(beings, Zmobies.Being.on_top_of?(being)) ->
        {:error, "#{being} is trying to place on an occupied space."}
      true ->
        new_world = %{world | beings: world.beings ++ [being]}
        {:ok, new_world}
    end
  end

  def add(world) do
    %{right_boundary: right_boundary, bottom_boundary: bottom_boundary} = world

    being = Zmobies.Being.new(
      col: :random.uniform(right_boundary),
      row: :random.uniform(bottom_boundary)
    )

    add(world, being)
  end
end

defimpl String.Chars, for: Zmobies.World do
  # necessary for IO.puts
  def to_string(%Zmobies.World{bottom_boundary: bottom_boundary, right_boundary: right_boundary, beings: beings}) do
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
      %Zmobies.Being{} -> 'X'
      _ -> 'O'
    end
  end
end
