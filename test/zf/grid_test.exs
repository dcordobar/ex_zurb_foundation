defmodule Zf.GridTest do
  use ExUnit.Case
  doctest Zf.Grid

  setup_all do
    {:ok,
      grid_default: [[content: "Some content", class: "small-12"], [content: "Some content", class: "small-12"]],
      grid_custom: [[tag: :li, content: "Some content", class: "small-12"], [tag: :li, content: "Some content", class: "small-12"]],
      grid_map: [%{content: "Some content", class: "small-12"}, %{content: "Some content", class: "small-12"}],
    }
  end

  test "spawn foundation grid with default tag elements", params do

    expected = {:safe, [60, "div", [[32, "class", 61, 34, "expanded align-middle row", 34]], 62,
      [[60, "div", [[32, "class", 61, 34, "small-12 columns", 34]], 62,
        "Some content", 60, 47, "div", 62],
      [60, "div", [[32, "class", 61, 34, "small-12 columns", 34]], 62,
        "Some content", 60, 47, "div", 62]], 60, 47, "div", 62]
    }

    assert expected == Zf.Grid.get([class: "expanded align-middle"], params[:grid_default])

  end

  test "spawn foundation grid with custom tag elements", params do

    expected = {:safe, [60, "ul", [[32, "class", 61, 34, "expanded align-middle row", 34]], 62,
      [[60, "li", [[32, "class", 61, 34, "small-12 columns", 34]], 62,
        "Some content", 60, 47, "li", 62],
      [60, "li", [[32, "class", 61, 34, "small-12 columns", 34]], 62,
        "Some content", 60, 47, "li", 62]], 60, 47, "ul", 62]
    }

    assert expected == Zf.Grid.get([class: "expanded align-middle", tag: :ul], params[:grid_custom])

  end

  test "spawn foundation grid when content is a list of maps", params do

    expected = {:safe, [60, "div", [[32, "class", 61, 34, "expanded align-middle row", 34]], 62,
      [[60, "div", [[32, "class", 61, 34, "small-12 columns", 34]], 62,
        "Some content", 60, 47, "div", 62],
      [60, "div", [[32, "class", 61, 34, "small-12 columns", 34]], 62,
        "Some content", 60, 47, "div", 62]], 60, 47, "div", 62]
    }

    assert expected == Zf.Grid.get([class: "expanded align-middle"], params[:grid_map])

  end

  test "spawn foundation grid when options contains id attribute", params do
    expected = {:safe, [60, "div", [[32, "class", 61, 34, "expanded align-middle row", 34], [32, "id", 61, 34, "some-id-name", 34]], 62,
      [[60, "div", [[32, "class", 61, 34, "small-12 columns", 34]], 62,
        "Some content", 60, 47, "div", 62],
      [60, "div", [[32, "class", 61, 34, "small-12 columns", 34]], 62,
        "Some content", 60, 47, "div", 62]], 60, 47, "div", 62]
    }

    assert expected == Zf.Grid.get([class: "expanded align-middle", id: "some-id-name"], params[:grid_default])
  end
end
