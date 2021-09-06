defmodule TalioWeb.Internals.ElementsController do
  use TalioWeb, :controller

  alias Talio.{Accounts, Repo, Element}

  import Ecto.Query

  action_fallback TalioWeb.API.V1.FallbackController

  def create(conn, %{"elements" => elements} = _params) do
    # IO.inspect(elements)
    Element |> Repo.insert_all(elements)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(204, "")
  end
end
