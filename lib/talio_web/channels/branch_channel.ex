defmodule TalioWeb.BranchChannel do
  use Phoenix.Channel

  require Logger

  alias Talio.{
    Repo,
    Branch
  }

  def join("branch:public", _message, socket) do
    {:error, %{reason: "Unauthorized"}}
  end

  def join("branch:" <> fingerprint, _params, socket) do
    send(self(), :validate_website)

    unless TalioWeb.UserSocket.validate_snapshot_limits(
             socket.assigns.website,
             socket.assigns.snapshot
           ) do
      send(self(), :end_session)
    end

    send(self(), :initialize_user)

    {:ok, socket}
  end

  # 
  # Client API
  # 

  def handle_in("refresh_nonce", _payload, socket) do
    nonce = Talio.generate_nonce()
    ConCache.get_or_store(:talio_nonce_cache, socket.assigns.talio_user_id, fn -> nonce end)

    {:reply, {:ok, %{nonce: nonce}}, socket}
  end

  def handle_in("store_branch", payload, socket) do
    send(self(), {:validate_nonce, payload})

    # Store Branch Into Cache
    branch =
      ConCache.get_or_store(:talio_branches_cache, payload["fingerprint"], fn ->
        Branch.find_or_create(
          socket.assigns.website,
          socket.assigns.snapshot,
          [:fingerprint],
          %{fingerprint: to_string(payload["fingerprint"])}
        )
      end)

    # Take Screenshot From Different Devices
    # if branch.screenshot_status === 0 do
    socket |> take_screenshots(branch)
    # end

    {:reply, :ok, socket}
  end

  # 
  # Server API
  # 

  # Send Users Unique Talio ID
  def handle_info(:initialize_user, socket) do
    # Store Generated Nonce For Talio User ID Into Cache
    cached_nonce = Talio.get_or_store_nonce(socket.assigns.talio_user_id)

    # And Assign The Nonce To User's Socket Connection
    socket = socket |> assign(:nonce, cached_nonce)

    push(socket, "initialize_user", %{
      talio_user_id: socket.assigns.talio_user_id,
      nonce: cached_nonce
    })

    {:noreply, socket}
  end

  # Validate Users Nonce
  def handle_info({:validate_nonce, %{"nonce" => user_nonce} = _payload}, socket) do
    nonce = Talio.get_or_store_nonce(socket.assigns.talio_user_id)

    if nonce !== user_nonce || nonce !== socket.assigns.nonce do
      send(self(), :end_session)
    end

    # Delete Nonce
    ConCache.delete(:talio_nonce_cache, socket.assigns.talio_user_id)

    {:noreply, socket}
  end

  # Validate Necessary Conditions
  def handle_info(:validate_website, socket) do
    # If Website/Snapshot Not Found, Terminate User Connection
    if is_nil(socket.assigns.website) ||
         is_nil(socket.assigns.snapshot) ||
         is_nil(socket.assigns.origin_host) do
      send(self(), :end_session)
    else
      # Check Origin URL
      # socket.assigns.origin_host === socket.assigns.website.host 
      if !socket.assigns.website.is_verified, do: send(self(), :end_session)
    end

    {:noreply, socket}
  end

  # Terminate User Connection
  def handle_info(:end_session, socket) do
    Logger.error("Ending Session")
    push(socket, "end_session", %{})
    {:stop, :normal, socket}
  end

  #
  # Private Functions
  #

  # Take Screenshot From Different Devices
  defp take_screenshots(socket, branch) do
    Enum.each(0..2, fn device_type ->
      # IO.inspect(socket.assigns.snapshot.path)

      Branch.take_screenshot(socket.assigns.snapshot, branch, %{
        quality: 70,
        url: socket.assigns.website.url <> socket.assigns.snapshot.path,
        branch_id: branch.id,
        device_type: device_type,
        timeout: 120_000,
        recv_timeout: 120_000
      })
    end)
  end
end
