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

```elixir
<%= Zf.Grid.get([class: "expanded align-middle"], [[content: "Some content", class: "small-12"]]) %>

<%= Zf.Grid.get([class: "expanded align-middle"], [%{content: "Some content", class: "small-12"}]) %>
```
