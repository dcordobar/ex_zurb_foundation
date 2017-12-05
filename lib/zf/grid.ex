defmodule Zf.Grid do
  @moduledoc """
  Documentation for Zf.Grid
  """

  @doc """
  Zurb Foundation Grid.

  ## Examples

      iex> Zf.Grid.zf_grid([class: "expanded align-middle"], [[content: "Some content", class: "small-12"], [content: "Some content", class: "small-12"]])
      {:safe,
       [60, "div", [[32, "class", 61, 34, "expanded align-middle row", 34]], 62,
        [[60, "div", [[32, "class", 61, 34, "small-12 columns", 34]], 62,
          "Some content", 60, 47, "div", 62],
         [60, "div", [[32, "class", 61, 34, "small-12 columns", 34]], 62,
          "Some content", 60, 47, "div", 62]], 60, 47, "div", 62]}

  """

  import Phoenix.HTML.Tag

  def zf_grid(options, contents),
    do: row(options, contents |> Enum.map(fn(content) -> col(content) end))


  def row(options, content) when is_list(options),
    do: row(Enum.into(options, %{}), content)

  def row(options, content),
    do: default_tag(options[:tag]) |> content_tag(content, options |> Map.drop([:tag]) |> Map.merge(%{class: "#{options[:class]} row"}) |> Map.to_list)


  def col(nil),
    do: ""

  def col(content),
    do: default_tag(content[:tag]) |> content_tag(content[:content], [class: "#{content[:class]} columns"])


  defp default_tag(nil),
    do: :div

  defp default_tag(tag) when is_atom(tag),
    do: tag

  defp default_tag(tag),
    do: String.to_atom(tag)

end
