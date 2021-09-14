defmodule TalioWeb.UserSocket do
  use Phoenix.Socket

  require Logger

  alias Talio.{Repo, Website, PageView, Snapshot}

  import Ecto.Query

  # 
  # Channels
  # 
  channel "click:public", TalioWeb.ClickChannel
  channel "branch:*", TalioWeb.BranchChannel

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

    case website do
      nil ->
        socket =
          socket
          |> assign(:website, nil)
          |> assign(:snapshot, nil)
          |> assign(:talio_user_id, user_id)
          |> assign(:origin_host, nil)

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

        # Increase Snapshot's Page View
        unless is_nil(snapshot), do: add_page_view(user_id, snapshot)

        socket =
          socket
          |> assign(:website, website)
          |> assign(:snapshot, snapshot)
          |> assign(:talio_user_id, user_id)
          |> assign(:origin_host, connect_info.uri.host)

        # IO.inspect(snapshot)
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
    PageView.changeset(%PageView{}, %{talio_user_id: talio_user_id})
    |> Ecto.Changeset.put_assoc(:snapshot, snapshot)
    |> Repo.insert()
  end

  # TODO: Make it a cache, Code a page_views for each snapshot
  defp count_snapshot_page_views(snapshot_id) do
    Repo.one(
      from page_view in PageView,
        join: snapshot in Snapshot,
        on: snapshot.id == ^snapshot_id,
        select: count("*")
    )
  end

  # Currently we only calculate and validate Snapshots "Page Views"
  def validate_snapshot_limits(_website, snapshot) when is_nil(snapshot) do
    :snapshot_not_found
  end

  def validate_snapshot_limits(website, snapshot) do
    snapshot_page_views = count_snapshot_page_views(snapshot.id)
    snapshot_limits = website.transaction.plan.limits["snapshot"]
    # IO.inspect(snapshot_limits)
    # IO.inspect(snapshot_page_views)
    snapshot_limits["page_views"] > snapshot_page_views
  end
end
