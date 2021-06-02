defmodule TalioWeb.UserSocket do
  use Phoenix.Socket

  require Logger

  alias Talio.{Repo, Website, PageView, Snapshot}

  import Ecto.Query

  ## Channels
  channel "click:*", TalioWeb.ClickChannel

  @impl true
  def connect(%{"website" => website_params} = _params, socket, connect_info) do
    # Generate The Talio Unique User ID From User's IP
    user_id = generate_user_id(connect_info)

    # Find The Recieved Website From Params
    website =
      Repo.one(
        from website in Website,
          where: website.host == ^website_params["host"],
          left_join: transaction in assoc(website, :transaction),
          left_join: plan in assoc(transaction, :plan),
          preload: [transaction: {transaction, plan: plan}]
      )

    IO.inspect(website)

    case website do
      nil ->
        socket =
          socket
          |> assign(:website, nil)
          |> assign(:snapshot, nil)
          |> assign(:talio_user_id, user_id)

        {:ok, socket}

      website ->
        # Find Snapshot
        snapshot =
          Repo.one(
            from snapshot in Talio.Snapshot,
              join: website in Talio.Website,
              on: website.id == snapshot.website_id,
              where: snapshot.path == ^website_params["path"]
          )

        # Increment Page View
        add_page_view(user_id, snapshot)

        # Check website limits
        validate_website_limits(website, snapshot)

        socket =
          socket
          |> assign(:website, website)
          |> assign(:snapshot, snapshot)
          |> assign(:talio_user_id, user_id)

        {:ok, socket}
    end
  end

  @impl true
  def id(socket), do: "users_socket:#{socket.assigns.talio_user_id}"

  defp generate_user_id(connect_info) do
    connect_info.peer_data.address
    |> Tuple.to_list()
    |> Enum.join(".")
    # Generates Unique Random Number From User's IP
    |> :erlang.phash2()
  end

  defp add_page_view(talio_user_id, snapshot) do
    page_view_changeset =
      PageView.changeset(%PageView{}, %{talio_user_id: talio_user_id})
      |> Ecto.Changeset.put_assoc(:snapshot, snapshot)
      |> Repo.insert()
  end

  defp count_page_views(snapshot_id) do
    Repo.one(
      from page_view in PageView,
        join: snapshot in Snapshot,
        on: snapshot.id == ^snapshot_id,
        select: count("*")
    )
  end

  def validate_website_limits(website, snapshot) do
    snapshot_page_views = count_page_views(snapshot.id)
    website_plan_limits = website.transaction.plan.limits
  end
end
