defmodule Zf.Grid do
  @moduledoc """
  Documentation for Zf.Grid
  """

  @doc """
  Zurb Foundation Grid.

  ## Examples

      iex> Zf.Grid.create([class: "expanded align-middle"], [[content: "Some content", class: "small-12"], [content: "Some content", class: "small-12"]])
      {:safe,
       [60, "div", [[32, "class", 61, 34, "expanded align-middle row", 34]], 62,
        [[60, "div", [[32, "class", 61, 34, "small-12 columns", 34]], 62,
          "Some content", 60, 47, "div", 62],
         [60, "div", [[32, "class", 61, 34, "small-12 columns", 34]], 62,
          "Some content", 60, 47, "div", 62]], 60, 47, "div", 62]}

  """

  import Phoenix.HTML.Tag

  def create(options, contents) do
    row(options, contents |> Enum.map(fn(content) -> col(content) end))
  end

  def row(options, content) do
    opts = [class: "#{options[:class]} row"]

    content_tag(default_tag(options[:tag]), content, opts)
  end

  def col(content) do
    opts = [class: "#{content[:class]} columns"]

    content_tag(default_tag(content[:tag]), content[:content], opts)
  end

  defp default_tag(nil), do: :div
  defp default_tag(tag) when is_atom(tag), do: tag
  defp default_tag(tag), do: String.to_atom(tag)
end
