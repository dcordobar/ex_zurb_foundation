defmodule Zf.Paginator do
 use Phoenix.HTML
  @defaults [action: :index, page_param: :page]
  @raw_defaults [distance: 5, next: ">>", previous: "<<", first: true, last: true, ellipsis: raw("&hellip;")]

  @moduledoc """
  For use with Phoenix.HTML, configure the `:routes_helper` module like the following:

      config :zf,
        routes_helper: MyApp.Router.Helpers

  Import to you view.

      defmodule MyApp.UserView do
        use MyApp.Web, :view
        use Zf.Paginator
      end

  Use in your template.

      <%= get @conn, @page %>

  Where `@page` is a `%Scrivener.Page{}` struct returned from `Repo.paginate/2`.

  Customize output. Below are the defaults.

      <%= get @conn, @page, distance: 5, next: ">>", previous: "<<", first: true, last: true %>

  See `Zf.Paginator.raw_get/2` for option descriptions.

  For custom HTML output, see `Zf.Paginator.raw_get/2`.

  For SEO related functions, see `Zf.Paginator.SEO` (these are automatically imported).
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import Zf.Paginator
      import Zf.Paginator.SEO
    end
  end

  defmodule Default do
    @doc ~S"""
    Default path function when none provided. Used when automatic path function
    resolution cannot be performed.

        iex> Zf.Paginator.Default.path(%Plug.Conn{}, :index, page: 4)
        "?page=4"
    """
    def path(_conn, _action, opts \\ []) do
      ("?" <> Plug.Conn.Query.encode(opts))
    end
  end

  @doc ~S"""
  Generates the HTML pagination links for a given paginator returned by Scrivener.

  The default options are:

      #{inspect @defaults}

  In order to generate links with nested objects (such as a list of comments for a given post)
  it is necessary to pass those arguments. All arguments in the `args` parameter will be directly
  passed to the path helper function. Everything within `opts` which are not options will passed
  as `params` to the path helper function. For example, `@post`, which has an index of paginated
  `@comments` would look like the following:

      Zf.Paginator.get(@conn, @comments, [@post], my_param: "foo")

  You'll need to be sure to configure `:zf` with the `:routes_helper`
  module (ex. MyApp.Routes.Helpers) in Phoenix. With that configured, the above would generate calls
  to the `post_comment_path(@conn, :index, @post.id, my_param: "foo", page: page)` for each page link.

  In times that it is necessary to override the automatic path function resolution, you may supply the
  correct path function to use by adding an extra key in the `opts` parameter of `:path`.
  For example:

      Zf.Paginator.get(@conn, @comments, [@post], path: &post_comment_path/4)

  Be sure to supply the function which accepts query string parameters (starts at arity 3, +1 for each relation),
  because the `page` parameter will always be supplied. If you supply the wrong function you will receive a
  function undefined exception.
  """

  def get(conn, paginator, args, opts) do
    merged_opts = Keyword.merge @defaults, opts
    path = opts[:path] || find_path_fn(conn && paginator.entries, args)
    params = Keyword.drop opts, (Keyword.keys(@defaults) ++ [:path])

    # Ensure ordering so pattern matching is reliable
    _get paginator,
      path: path,
      args: [conn, merged_opts[:action]] ++ args,
      page_param: merged_opts[:page_param],
      params: params
  end
  def get(%Scrivener.Page{} = paginator) do
    get(nil, paginator, [], [])
  end
  def get(%Scrivener.Page{} = paginator, opts) do
    get(nil, paginator, [], opts)
  end
  def get(conn, %Scrivener.Page{} = paginator) do
    get(conn, paginator, [], [])
  end
  def get(conn, paginator, [{_, _} | _] = opts) do
    get(conn, paginator, [], opts)
  end
  def get(conn, paginator, [_ | _] = args) do
    get(conn, paginator, args, [])
  end

  def find_path_fn(nil, _path_args), do: &Default.path/3
  def find_path_fn([], _path_args), do: fn _, _, _ -> nil end
  # Define a different version of `find_path_fn` whenever Phoenix is available.
  if Code.ensure_loaded(Phoenix.Naming) do
    def find_path_fn(entries, path_args) do
      routes_helper_module = Application.get_env(:zf, :routes_helper) || raise("Zf.Paginator: Unable to find configured routes_helper module (ex. MyApp.Router.Helper)")
      path = (path_args) |> Enum.reduce(name_for(List.first(entries), ""), &name_for/2)
      {path_fn, []} = Code.eval_quoted(quote do: &unquote(routes_helper_module).unquote(:"#{path <> "_path"}")/unquote(length(path_args) + 3))
      path_fn
    end
  else
    def find_path_fn(_entries, _args), do: &Default/3
  end

  defp name_for(model, acc) do
    "#{acc}#{if(acc != "", do: "_")}#{Phoenix.Naming.resource_name(model.__struct__)}"
  end

  defp _get(paginator, [path: path, args: args, page_param: page_param, params: params]) do
    url_params = Keyword.drop params, Keyword.keys(@raw_defaults)

    content_tag :ul, class: "pagination", role: "pagination" do
      raw_get(paginator, params)
      |> Enum.map(&page(&1, url_params, args, page_param, path, paginator))
    end
  end

  defp page({:ellipsis, true}, url_params, args, page_param, path, paginator) do
    page({:ellipsis, ""}, url_params, args, page_param, path, paginator)
  end
  defp page({:ellipsis, _text}, _url_params, _args, _page_param, _path, paginator) do
    content_tag(:li, "", class: li_classes_for_style(paginator, :ellipsis) |> Enum.join(" "))
  end

  defp page({text, page_number}, url_params, args, page_param, path, paginator) do
    params_with_page = url_params ++ [{page_param, page_number}]
    content_tag :li, class: li_classes_for_style(paginator, page_number) |> Enum.join(" ") do
      to = apply(path, args ++ [params_with_page])
      if to do
        link(safe(text), to: to, rel: Zf.Paginator.SEO.rel(paginator, page_number), class: link_classes_for_style(paginator, page_number) |> Enum.join(" "))
      else
        content_tag(:span, safe(text), class: link_classes_for_style(paginator, page_number) |> Enum.join(" "))
      end
    end
  end

  defp li_classes_for_style(_paginator, :ellipsis), do: ["ellipsis"]
  defp li_classes_for_style(paginator, page_number) do
    if(paginator.page_number == page_number, do: ["current"], else: [])
  end

  defp link_classes_for_style(_paginator, _page_number) do
    []
  end

  @doc """
  Returns the raw data in order to generate the proper HTML for pagination links. Data
  is returned in a `{text, page_number}` format where `text` is intended to be the text
  of the link and `page_number` is the page it should go to. Defaults are already supplied
  and they are as follows:

      #{inspect @raw_defaults}

  `distance` must be a positive non-zero integer or an exception is raised. `next` and `previous` should be
  strings but can be anything you want as long as it is truthy, falsey values will remove
  them from the output. `first` and `last` are only booleans, and they just include/remove
  their respective link from output. An example of the data returned:

      iex> Zf.Paginator.raw_get(%{total_pages: 10, page_number: 5})
      [{"<<", 4}, {1, 1}, {2, 2}, {3, 3}, {4, 4}, {5, 5}, {6, 6}, {7, 7}, {8, 8}, {9, 9}, {10, 10}, {">>", 6}]
      iex> Zf.Paginator.raw_get(%{total_pages: 20, page_number: 10}, first: ["←"], last: ["→"])
      [{"<<", 9}, {["←"], 1}, {:ellipsis, {:safe, "&hellip;"}}, {5, 5}, {6, 6},{7, 7}, {8, 8}, {9, 9}, {10, 10}, {11, 11}, {12, 12}, {13, 13}, {14, 14},{15, 15}, {:ellipsis, {:safe, "&hellip;"}}, {["→"], 20}, {">>", 11}]

  Simply loop and pattern match over each item and transform it to your custom HTML.
  """
  def raw_get(paginator, options \\ []) do

    options = Keyword.merge @raw_defaults, options

    add_first(paginator.page_number, options[:distance], options[:first])
    |> add_first_ellipsis(paginator.page_number, paginator.total_pages, options[:distance], options[:first])
    |> add_previous(paginator.page_number)
    |> page_number_list(paginator.page_number, paginator.total_pages, options[:distance])
    |> add_last_ellipsis(paginator.page_number, paginator.total_pages, options[:distance], options[:last])
    |> add_last(paginator.page_number, paginator.total_pages, options[:distance], options[:last])
    |> add_next(paginator.page_number, paginator.total_pages)
    |> Enum.map(fn
      :next -> if options[:next], do: {options[:next], paginator.page_number + 1}
      :previous -> if options[:previous], do: {options[:previous], paginator.page_number - 1}
      :first_ellipsis -> if options[:ellipsis] && options[:first], do: {:ellipsis, options[:ellipsis]}
      :last_ellipsis -> if options[:ellipsis] && options[:last], do: {:ellipsis, options[:ellipsis]}
      :first -> if options[:first], do: {options[:first], 1}
      :last -> if options[:last], do: {options[:last], paginator.total_pages}
      num when is_number(num) -> {num, num}
    end) |> Enum.filter(&(&1))
  end

  # Computing page number ranges
  defp page_number_list(list, page, total, distance) when is_integer(distance) and distance >= 1 do
    list ++ Enum.to_list(beginning_distance(page, total, distance)..end_distance(page, total, distance))
  end
  defp page_number_list(_list, _page, _total, _distance) do
    raise "Zf.Paginator: Distance cannot be less than one."
  end

  # Beginning distance computation
  # For low page numbers
  defp beginning_distance(page, _total, distance) when page - distance < 1 do
    page - (distance + (page - distance - 1))
  end
  # For medium to high end page numbers
  defp beginning_distance(page, total, distance) when page <= total  do
    page - distance
  end
  # For page numbers over the total number of pages (prevent DOS attack generating too many pages)
  defp beginning_distance(page, total, distance) when page > total do
    total - distance
  end

  # End distance computation
  # For high end page numbers (prevent DOS attack generating too many pages)
  defp end_distance(page, total, distance) when page + distance >= total and total != 0 do
    total
  end
  # For when there is no pages, cannot trust page number because it is supplied by user potentially (prevent DOS attack)
  defp end_distance(_page, 0, _distance) do
    1
  end
  # For low to mid range page numbers (guard here to ensure crash if something goes wrong)
  defp end_distance(page, total, distance) when page + distance < total do
    page + distance
  end

  # Adding next/prev/first/last links
  defp add_previous(list, page) when page != 1 do
    [:previous | list]
  end
  defp add_previous(list, _page) do
    list
  end

  defp add_first(page, distance, true) when page - distance > 1 do
    [1]
  end
  defp add_first(page, distance, first) when page - distance > 1 and first != false do
    [:first]
  end
  defp add_first(_page, _distance, _included) do
    []
  end

  defp add_last(list, page, total, distance, true) when page + distance < total do
    list ++ [total]
  end
  defp add_last(list, page, total, distance, last) when page + distance < total and last != false do
    list ++ [:last]
  end
  defp add_last(list, _page, _total, _distance, _included) do
    list
  end

  defp add_next(list, page, total) when page != total and page < total do
    list ++ [:next]
  end
  defp add_next(list, _page, _total) do
    list
  end

  defp add_first_ellipsis(list, page, total, distance, true) do
    add_first_ellipsis(list, page,total, distance + 1, nil)
  end

  defp add_first_ellipsis(list, page, _total, distance, _first) when page - distance > 1 and page > 1 do
    list ++ [:first_ellipsis]
  end
  defp add_first_ellipsis(list, _page_number, _total, _distance, _first) do
    list
  end

  defp add_last_ellipsis(list, page, total, distance, true) do
    add_last_ellipsis(list, page, total, distance + 1, nil)
  end

  defp add_last_ellipsis(list, page, total, distance, _) when page + distance < total and page != total do
    list ++ [:last_ellipsis]
  end
  defp add_last_ellipsis(list, _page_number, _total, _distance, _last) do
    list
  end

  defp safe({:safe, _string} = whole_string) do
    whole_string
  end
  defp safe(string) when is_binary(string) do
    string
  end
  defp safe(string) do
    string
    |> to_string()
    |> raw()
  end

  def defaults(), do: @defaults
end
