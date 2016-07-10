defmodule Zmobies.Map do
  alias Zmobies.Map, as: Map
  alias Zmobies.Being, as: Being

  defstruct bottom_boundary: 10, right_boundary: 10, beings: []

  def new, do: %Map{}

  def new(bottom_boundary, right_boundary) do
    %Map{bottom_boundary: bottom_boundary, right_boundary: right_boundary}
  end

  def move(map, old_being, new_being) do
    case remove(map, old_being) do
      {:ok, map_with_removal} ->
        add(map_with_removal, new_being)
      {:error, message} ->
        {:error, message}
    end
  end

  def remove(map, being) do
    new_map = %{map | beings: Enum.reject(map.beings, Being.same_location?(being))}
    {:ok, new_map}
  end

  def add(map,being) do
    %{
      right_boundary: right_boundary,
      bottom_boundary: bottom_boundary,
      beings: beings
    } = map

    collision = Enum.find(beings, Being.same_location?(being))

    cond do
      being.col_index < 1 ->
        {:error, "#{being} is out of bounds to the left"}
      being.col_index > right_boundary ->
        {:error, "#{being} is out of bounds to the right"}
      being.row_index < 1 ->
        {:error, "#{being} is out of bounds to the north"}
      being.row_index > bottom_boundary ->
        {:error, "#{being} is out of bounds to the south"}
      collision != nil ->
        {:collision, being, collision}
      true ->
        new_map = %{map | beings: map.beings ++ [being]}
        {:ok, new_map, being}
    end
  end

  def add_random(map, type) do
    %{right_boundary: right_boundary, bottom_boundary: bottom_boundary} = map

    being = Being.new(
      col: :random.uniform(right_boundary),
      row: :random.uniform(bottom_boundary),
      type: type
    )

    add(map, being)
  end

  def add_zombie(map), do: add_random(map, :zombie)
  def add_human(map), do: add_random(map, :human)

  def update_being(map, being) do
    {:ok, map_with_removal} = remove(map, being)
    add(map_with_removal, being)
  end

  def stable?(map) do
    available_types = map.beings
      |> Enum.map(fn(being) -> being.type end)
      |> Enum.uniq

    length(available_types) == 1
  end

  def winner(map) do
    case List.first(map.beings).type do
      :zombie -> "zombies"
      :human -> "humans"
    end
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
      %{type: :zombie} -> "#{IO.ANSI.red()}Z"
      %{type: :human} -> "#{IO.ANSI.yellow()}H"
      _ -> " "
    end
  end
end
