defmodule CodeCorps.GithubRepoController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.{GithubRepo}

  @preloads [:github_app_installation]

  plug :load_resource, model: GithubRepo, only: [:show], preload: @preloads

  plug JaResource

  @spec filter(Plug.Conn.t, Ecto.Query.t, String.t, String.t) :: Ecto.Query.t
  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end
end
