# Zurb Foundation for Elixir (Phoenix)

Helpers built to work with [Phoenix](http://www.phoenixframework.org)'s page struct to easily build HTML output for ZURB Foundation framework.

## Setup

Add to `mix.exs`

```elixir
  # add :zf to deps
  defp deps do
    [
      # ...
      {:zf, "~> 0.1"}
      # ...
    ]
  end

  # add :zf to applications list
  defp application do
    [
      # ...
      applications: [ ..., :zf, ... ]
      # ...
    ]
  end
```

## Example Usage

Use in your template.


### Grid

```elixir
<%= Zf.Grid.get([class: "expanded align-middle"], [[content: "Some content", class: "small-12"]]) %>

<%= Zf.Grid.get([class: "expanded align-middle"], [%{content: "Some content", class: "small-12"}]) %>
```

### Paginator

Helpers built to work with [Scrivener's page](https://github.com/drewolson/scrivener) struct to easily build HTML output for ZURB Foundation framework.

For use with Phoenix.HTML, configure the `:routes_helper` module in `config/config.exs`
like the following:

```elixir
config :scrivener_html,
  routes_helper: MyApp.Router.Helpers,
```

Import to your view.

```elixir
defmodule MyApp.UserView do
  use MyApp.Web, :view
  import Zf.Paginator
end
```

#### Example Usage

Use in your template.

```elixir
<%= for user <- @page do %>
   ...
<% end %>

<%= Zf.Paginator.get @page %>
```

Where `@page` is a `%Scrivener.Page{}` struct returned from `Repo.paginate/2`.
So the function in your controller is like:

```elixir
#  params = %{"page" => _page}
def index(conn, params) do
  page = MyApp.User
          # Other query conditions can be done here
          |> MyApp.Repo.paginate(params)
  render conn, "index.html", page: page
end
```

#### Scopes and URL Parameters

If your resource has any url parameters to be supplied, you should provide them as the 3rd parameter. For example, given a scope like:

```elixir
scope "/:locale", App do
  pipe_through [:browser]

  get "/page", PageController, :index, as: :pages
  get "/pages/:id", PageController, :show, as: :page
end
```

You would need to pass in the `:locale` parameter and `:path` option like so:

_(this would generate links like "/en/page?page=1")_

```elixir
<%= Zf.Paginator.get @conn, @page, ["en"], path: &pages_path/4 %>
```

With a nested resource, simply add it to the list:

_(this would generate links like "/en/pages/1?page=1")_

```elixir
<%= Zf.Paginator.get @conn, @page, ["en", @page_id], path: &page_path/4, action: :show %>
```

#### Query String Parameters

Any additional query string parameters can be passed in as well.

```elixir
<%= Zf.Paginator.get @conn, @page, ["en"], some_parameter: "data" %>
# Or if there are no URL parameters
<%= Zf.Paginator.get @conn, @page, some_parameter: "data" %>
```

#### Custom Actions

If you need to hit a different action other than `:index`, simply pass the action name to use in the url helper.

```elixir
<%= Zf.Paginator.get @conn, @page, action: :show %>
```

#### Customizing Output

Below are the defaults which are used without passing in any options.

```elixir
<%= Zf.Paginator.get @conn, @page, [], distance: 5, next: ">>", previous: "<<", first: true, last: true %>
# Which is the same as
<%= Zf.Paginator.get @conn, @page %>
```

To prevent HTML escaping (i.e. seeing things like `&lt;` on the page), simply use `Phoenix.HTML.raw/1` for any `&amp;` strings passed in, like so:

```elixir
<%= Zf.Paginator.get @conn, @page, previous: Phoenix.HTML.raw("&leftarrow;"), next: Phoenix.HTML.raw("&rightarrow;") %>
```

To show icons instead of text, simply render custom html templates, like:

_(this example uses materialize icons)_

```elixir
# Using Phoenix.HTML's sigil_E for EEx
<%= Zf.Paginator.get @conn, @page, previous: ~E(<i class="material-icons">chevron_left</i>), next: ~E(<i class="material-icons">chevron_right</i>) %>
# Or by calling render
<%= Zf.Paginator.get @conn, @page, previous: render("pagination.html", direction: :prev), next: render("pagination.html", direction: :next)) %>
```

The same can be done for first/last links as well (`v1.7.0` or higher).

_(this example uses materialize icons)_

```elixir
<%= Zf.Paginator.get @conn, @page, first: ~E(<i class="material-icons">chevron_left</i>), last: ~E(<i class="material-icons">chevron_right</i>) %>
```

### Extending

For custom HTML output, see `Zf.Paginator.get.raw_get/2`.

See `Zf.Paginator.raw_get/2` for option descriptions.

Zf.Paginator can be included in your view and then just used with a simple call to `get/1`.

```elixir
iex> Zf.Paginator.get(%Scrivener.Page{total_pages: 10, page_number: 5}) |> Phoenix.HTML.safe_to_string()
"<ul class=\"pagination\" role= \"pagination\">
  <li class=\"\"><a class=\"\" href=\"?page=4\">&lt;&lt;</a></li>
  <li class=\"\"><a class=\"\" href=\"?page=1\">1</a></li>
  <li class=\"\"><a class=\"\" href=\"?page=2\">2</a></li>
  <li class=\"\"><a class=\"\" href=\"?page=3\">3</a></li>
  <li class=\"\"><a class=\"\" href=\"?page=4\">4</a></li>
  <li class=\"current\">5</li>
  <li class=\"\"><a class=\"\" href=\"?page=6\">6</a></li>
  <li class=\"\"><a class=\"\" href=\"?page=7\">7</a></li>
  <li class=\"\"><a class=\"\" href=\"?page=8\">8</a></li>
  <li class=\"\"><a class=\"\" href=\"?page=9\">9</a></li>
  <li class=\"\"><a class=\"\" href=\"?page=10\">10</a></li>
  <li class=\"\"><a class=\"\" href=\"?page=6\">&gt;&gt;</a></li>
</ul>"
```

### SEO

SEO attributes like `rel` are automatically added to pagination links. In addition, a helper for header `<link>` tags is available (`v1.7.0` and higher) to be placed in the `<head>` tag.

See `Zf.Paginator.SEO` documentation for more information.
