defmodule Zf.PaginatorTest do
  use ExUnit.Case
  doctest Zf.Paginator
  import Zf.Paginator.Support.HTML
  alias Scrivener.Page

  setup do
    Application.put_env(:zf, :routes_helper, MyApp.Router.Helpers)
    :ok
  end

  describe "raw_get for a page" do

    test "in the middle" do
      assert pages(45..55) == links_with_opts total_pages: 100, page_number: 50
    end

    test ":distance from the first" do
      assert pages(1..10) == links_with_opts total_pages: 20, page_number: 5
    end

    test "2 away from the first" do
      assert pages(1..8) == links_with_opts total_pages: 10, page_number: 3
    end

    test "1 away from the first" do
      assert pages(1..7) == links_with_opts total_pages: 10, page_number: 2
    end

    test "at the first" do
      assert pages(1..6) == links_with_opts total_pages: 10, page_number: 1
    end

    test ":distance from the last" do
      assert pages(10..20) == links_with_opts total_pages: 20, page_number: 15
    end

    test "2 away from the last" do
      assert pages(3..10) == links_with_opts total_pages: 10, page_number: 8
    end

    test "1 away from the last" do
      assert pages(4..10) == links_with_opts total_pages: 10, page_number: 9
    end

    test "at the last" do
      assert pages(5..10) == links_with_opts total_pages: 10, page_number: 10
    end

    test "page value larger than total pages" do
      assert pages(5..10) == links_with_opts total_pages: 10, page_number: 100
    end

    test "with custom IO list as first" do
      assert pages_with_first({["←"], 1}, 5..15) == links_with_opts [total_pages: 20, page_number: 10], first: ["←"]
    end

    test "with custom IO list as last" do
      assert pages_with_last({["→"], 20}, 5..15) == links_with_opts [total_pages: 20, page_number: 10], last: ["→"]
    end

  end

  describe "raw_get next" do

    test "includes a next" do
      assert pages_with_next(45..55, 51) == links_with_opts [total_pages: 100, page_number: 50], next: ">>"
    end

    test "does not include next when equal to the total" do
      assert pages(5..10) == links_with_opts [total_pages: 10, page_number: 10], next: ">>"
    end

    test "can disable next" do
      assert pages(45..55) == links_with_opts [total_pages: 100, page_number: 50], next: false
    end

  end

  describe "raw_get previous" do

    test "includes a previous" do
      assert pages_with_previous(49, 45..55) == links_with_opts [total_pages: 100, page_number: 50], previous: "<<"
    end

    test "includes a previous before the first" do
      assert [{"<<", 49}, {1, 1}, {:ellipsis, Phoenix.HTML.raw("&hellip;")}] ++ pages(45..55) == links_with_opts [total_pages: 100, page_number: 50], previous: "<<", first: true
    end

    test "does not include previous when equal to page 1" do
      assert pages(1..6) == links_with_opts [total_pages: 10, page_number: 1], previous: "<<"
    end

    test "can disable previous" do
      assert pages(45..55) == links_with_opts [total_pages: 100, page_number: 50], previous: false
    end

  end

  describe "raw_get first" do

    test "includes the first" do
      assert pages_with_first(1, 5..15) == links_with_opts [total_pages: 20, page_number: 10], first: true
    end

    test "does not the include the first when it is already included" do
      assert pages(1..10) == links_with_opts [total_pages: 10, page_number: 5], first: true
    end

    test "can disable first" do
      assert pages(5..15) == links_with_opts [total_pages: 20, page_number: 10], first: false
    end

  end

  describe "raw_get last" do

    test "includes the last" do
      assert pages_with_last(20, 5..15) == links_with_opts [total_pages: 20, page_number: 10], last: true
    end

    test "does not the include the last when it is already included" do
      assert pages(1..10) == links_with_opts [total_pages: 10, page_number: 5], last: true
    end

    test "can disable last" do
      assert pages(5..15) == links_with_opts [total_pages: 20, page_number: 10], last: false
    end

  end

  describe "raw_get distance" do

    test "can change the distance" do
      assert pages(1..3) == links_with_opts [total_pages: 3, page_number: 2], distance: 1
    end

    test "does not allow negative distances" do
      assert_raise RuntimeError, "Zf.Paginator: Distance cannot be less than one.", fn ->
        links_with_opts [total_pages: 10, page_number: 5], distance: -5
      end
    end

  end

  describe "raw_get ellipsis" do

    test "includes ellipsis after first" do
      assert [{1, 1}, {:ellipsis, "&hellip;"}] ++ pages(45..55) == links_with_opts [total_pages: 100, page_number: 50], previous: false, first: true, ellipsis: "&hellip;"
    end

    test "includes ellipsis before last" do
      assert pages(5..15) ++ [{:ellipsis, "&hellip;"}, {20, 20}] == links_with_opts [total_pages: 20, page_number: 10], last: true, ellipsis: "&hellip;"
    end

    test "does not include ellipsis on first page" do
      assert pages(1..6) == links_with_opts [total_pages: 8, page_number: 1], first: true, ellipsis: "&hellip;"
    end

    test "uses ellipsis only beyond <distance> of first page" do
      assert pages(1..11) == links_with_opts [total_pages: 20, page_number: 6], first: true, ellipsis: "&hellip;"
      assert [{1, 1}] ++ pages(2..12) == links_with_opts [total_pages: 20, page_number: 7], first: true, ellipsis: "&hellip;"
    end

    test "when first/last are true, uses ellipsis only when (<distance> + 1) is greater than the total pages" do
      options = [first: true, last: true, distance: 1]

      assert pages(1..3) == links_with_opts [total_pages: 3, page_number: 1], options
      assert pages(1..3) == links_with_opts [total_pages: 3, page_number: 3], options
    end

    test "does not include ellipsis on last page" do
      assert pages(15..20) == links_with_opts [total_pages: 20, page_number: 20], last: true, ellipsis: "&hellip;"
    end

    test "uses ellipsis only beyond <distance> of last page" do
      assert pages(10..20) == links_with_opts [total_pages: 20, page_number: 15], last: true, ellipsis: "&hellip;"
      assert pages(9..19) ++ [{20, 20}] == links_with_opts [total_pages: 20, page_number: 14], last: true, ellipsis: "&hellip;"
    end

  end

  describe "get" do

    test "accepts a paginator and options (same as defaults)" do
      assert {:safe, _html} = Zf.Paginator.get(%Page{total_pages: 10, page_number: 5}, path: &MyApp.Router.Helpers.post_path/3)
    end

    test "supplies defaults" do
      assert {:safe, _html} = Zf.Paginator.get(%Page{total_pages: 10, page_number: 5})
    end

    test "allows options in any order" do
      assert {:safe, _html} = Zf.Paginator.get(%Page{total_pages: 10, page_number: 5}, path: &MyApp.Router.Helpers.post_path/3)
    end

    test "accepts an override action" do
      html = Zf.Paginator.get(%Page{total_pages: 10, page_number: 5}, action: :edit, path: &MyApp.Router.Helpers.post_path/3)
      assert Phoenix.HTML.safe_to_string(html) =~ ~r(\/posts\/:id\/edit)
    end

    test "accepts an override page param name" do
      html = Zf.Paginator.get(%Page{total_pages: 2, page_number: 2}, page_param: :custom_pp)
      assert Phoenix.HTML.safe_to_string(html) =~ ~r(custom_pp=2)
    end

    test "allows unicode" do
      html = Zf.Paginator.get(%Page{total_pages: 2, page_number: 2}, previous: "«")
      assert Phoenix.HTML.safe_to_string(html) == """
      <ul class=\"pagination\" role=\"pagination\"><li class=\"\"><a class=\"\" href=\"?page=1\" rel=\"prev\">«</a></li><li class=\"\"><a class=\"\" href=\"?page=1\" rel=\"prev\">1</a></li><li class=\"current\"><a class=\"\" href=\"?page=2\" rel=\"canonical\">2</a></li></ul>
      """ |> String.trim_trailing
    end

    test "allows using raw" do
      html = Zf.Paginator.get(%Page{total_pages: 2, page_number: 2}, previous: Phoenix.HTML.raw("&leftarrow;"))
      assert Phoenix.HTML.safe_to_string(html) == """
      <ul class=\"pagination\" role=\"pagination\"><li class=\"\"><a class=\"\" href=\"?page=1\" rel=\"prev\">&leftarrow;</a></li><li class=\"\"><a class=\"\" href=\"?page=1\" rel=\"prev\">1</a></li><li class=\"current\"><a class=\"\" href=\"?page=2\" rel=\"canonical\">2</a></li></ul>
      """ |> String.trim_trailing
    end

    test "accept nested keyword list for additionnal params" do
      html = Zf.Paginator.get(%Page{total_pages: 2, page_number: 2}, q: [name: "joe"])
      assert Phoenix.HTML.safe_to_string(html) =~ ~r(q\[name\]=joe)
    end
  end

  describe "Phoenix conn()" do
    test "handles no entries" do
      use Phoenix.ConnTest
      Application.put_env(:zf, :routes_helper, MyApp.Router.Helpers)

      assert {:safe, [60, "ul", [[32, "class", 61, 34, "pagination", 34], [32, "role", 61, 34, "pagination", 34]], 62,
                       [[60, "li", [[32, "class", 61, 34, "current", 34]], 62,
                         [60, "span", [[32, "class", 61, 34, "", 34]], 62, "1", 60, 47,
                          "span", 62], 60, 47, "li", 62]], 60, 47, "ul", 62]} =
        Zf.Paginator.get(build_conn(), %Page{entries: [], page_number: 1, page_size: 10, total_entries: 0, total_pages: 0})
    end

    test "allows other url parameters" do
      use Phoenix.ConnTest
      Application.put_env(:zf, :routes_helper, MyApp.Router.Helpers)

      assert "<ul class=\"pagination\" role=\"pagination\"><li class=\"current\"><a class=\"\" href=\"/posts?url_param=param&page=1\" rel=\"canonical\">1</a></li><li class=\"\"><a class=\"\" href=\"/posts?url_param=param&page=2\" rel=\"next\">2</a></li><li class=\"\"><a class=\"\" href=\"/posts?url_param=param&page=3\" rel=\"canonical\">3</a></li><li class=\"\"><a class=\"\" href=\"/posts?url_param=param&page=4\" rel=\"canonical\">4</a></li><li class=\"\"><a class=\"\" href=\"/posts?url_param=param&page=5\" rel=\"canonical\">5</a></li><li class=\"\"><a class=\"\" href=\"/posts?url_param=param&page=6\" rel=\"canonical\">6</a></li><li class=\"ellipsis\"></li><li class=\"\"><a class=\"\" href=\"/posts?url_param=param&page=20\" rel=\"canonical\">20</a></li><li class=\"\"><a class=\"\" href=\"/posts?url_param=param&page=2\" rel=\"next\">&gt;&gt;</a></li></ul>" ==
        Zf.Paginator.get(build_conn(), %Page{entries: [%{__struct__: Post, some: :object}], page_number: 1, page_size: 10, total_entries: 200, total_pages: 20}, url_param: "param")
        |> Phoenix.HTML.safe_to_string()
    end
  end

  describe "Renders" do
    use Phoenix.ConnTest

    test "without ellipsis" do
      assert {:safe, [60, "ul",
                      [[32, "class", 61, 34, "pagination", 34],
                       [32, "role", 61, 34, "pagination", 34]], 62,
                      [[60, "li", [[32, "class", 61, 34, "current", 34]], 62,
                        [60, "span", [[32, "class", 61, 34, "", 34]], 62, "1", 60, 47,
                         "span", 62], 60, 47, "li", 62],
                       [60, "li", [[32, "class", 61, 34, "", 34]], 62,
                        [60, "span", [[32, "class", 61, 34, "", 34]], 62, "2", 60, 47,
                         "span", 62], 60, 47, "li", 62],
                       [60, "li", [[32, "class", 61, 34, "", 34]], 62,
                        [60, "span", [[32, "class", 61, 34, "", 34]], 62, "&gt;&gt;",
                         60, 47, "span", 62], 60, 47, "li", 62]], 60, 47, "ul", 62]} =
        Zf.Paginator.get(build_conn(), %Page{entries: [], page_number: 1, page_size: 10, total_entries: 20, total_pages: 2})
    end

    test "with ellipsis" do
      assert {:safe, [60, "ul",
                       [[32, "class", 61, 34, "pagination", 34],
                        [32, "role", 61, 34, "pagination", 34]], 62,
                       [[60, "li", [[32, "class", 61, 34, "", 34]], 62,
                         [60, "span", [[32, "class", 61, 34, "", 34]], 62, "&lt;&lt;", 60, 47, "span",
                          62], 60, 47, "li", 62],
                        [60, "li", [[32, "class", 61, 34, "", 34]], 62,
                         [60, "span", [[32, "class", 61, 34, "", 34]], 62, "1", 60, 47, "span", 62],
                         60, 47, "li", 62],
                        [60, "li", [[32, "class", 61, 34, "", 34]], 62,
                         [60, "span", [[32, "class", 61, 34, "", 34]], 62, "2", 60, 47, "span", 62],
                         60, 47, "li", 62],
                        [60, "li", [[32, "class", 61, 34, "current", 34]], 62,
                         [60, "span", [[32, "class", 61, 34, "", 34]], 62, "3", 60, 47, "span", 62],
                         60, 47, "li", 62],
                        [60, "li", [[32, "class", 61, 34, "", 34]], 62,
                         [60, "span", [[32, "class", 61, 34, "", 34]], 62, "4", 60, 47, "span", 62],
                         60, 47, "li", 62],
                        [60, "li", [[32, "class", 61, 34, "", 34]], 62,
                         [60, "span", [[32, "class", 61, 34, "", 34]], 62, "5", 60, 47, "span", 62],
                         60, 47, "li", 62],
                        [60, "li", [[32, "class", 61, 34, "", 34]], 62,
                         [60, "span", [[32, "class", 61, 34, "", 34]], 62, "6", 60, 47, "span", 62],
                         60, 47, "li", 62],
                        [60, "li", [[32, "class", 61, 34, "", 34]], 62,
                         [60, "span", [[32, "class", 61, 34, "", 34]], 62, "7", 60, 47, "span", 62],
                         60, 47, "li", 62],
                        [60, "li", [[32, "class", 61, 34, "", 34]], 62,
                         [60, "span", [[32, "class", 61, 34, "", 34]], 62, "8", 60, 47, "span", 62],
                         60, 47, "li", 62],
                        [60, "li", [[32, "class", 61, 34, "ellipsis", 34]], 62, "",
                         60, 47, "li", 62],
                        [60, "li", [[32, "class", 61, 34, "", 34]], 62,
                         [60, "span", [[32, "class", 61, 34, "", 34]], 62, "10", 60, 47, "span", 62],
                         60, 47, "li", 62],
                        [60, "li", [[32, "class", 61, 34, "", 34]], 62,
                         [60, "span", [[32, "class", 61, 34, "", 34]], 62, "&gt;&gt;", 60, 47, "span",
                          62], 60, 47, "li", 62]], 60, 47, "ul", 62]} ==
        Zf.Paginator.get(build_conn(), %Page{entries: [], page_number: 3, page_size: 10, total_entries: 100, total_pages: 10}, ellipsis: true)
    end

  end
end
