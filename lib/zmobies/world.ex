defmodule Zmobies.World do
  defstruct bottom_boundary: 10, right_boundary: 10

  def new, do: %Zmobies.World{}

  def new(bottom_boundary, right_boundary) do
    %Zmobies.World{bottom_boundary: bottom_boundary, right_boundary: right_boundary}
  end
end

defimpl String.Chars, for: Zmobies.World do
  # necessary for IO.puts
  def to_string(%Zmobies.World{bottom_boundary: bottom_boundary, right_boundary: right_boundary}) do
    1..bottom_boundary
      |> Enum.to_list
      |> Enum.map(fn(_) -> print_row(right_boundary) end)
      |> Enum.join("\n")
  end

  defp print_row(boundary) do
    1..boundary
      |> Enum.to_list
      |> Enum.map(fn(_) -> 'O' end)
      |> Enum.join(" ")
  end
end
