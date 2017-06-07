defmodule MyApp.Router.Helpers do

  def post_path(_conn, :index, params) do
    {:safe, "/posts#{query_params(params)}"}
  end
  def post_path(_conn, :edit, params) do
    {:safe, "/posts/:id/edit#{query_params(params)}"}
  end
  def post_comment_path(_conn, :index, post_id, params), do: {:safe, "/posts/#{post_id}#{query_params(params)}"}

  defp query_params(params) do
    Enum.reduce params, "?", fn {k, v}, s ->
      "#{s}#{if(s == "?", do: "", else: "&")}#{k}=#{v}"
    end
  end

end
