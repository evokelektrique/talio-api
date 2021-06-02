defmodule Talio.Element do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query
  import TalioWeb.Gettext

  alias __MODULE__

  alias Talio.{
    Website,
    Branch,
    Repo,
    Click
  }

  @required_params [
    :width,
    :height,
    :x,
    :y,
    :path,
    :tag_name,
    :top,
    :right,
    :bottom,
    :left,
    :device
  ]

  @device_types %{
    0 => gettext("Desktop"),
    1 => gettext("Tablet"),
    2 => gettext("Mobile")
  }

  schema "elements" do
    field :width, :decimal
    field :height, :decimal
    field :top, :decimal
    field :right, :decimal
    field :bottom, :decimal
    field :left, :decimal
    field :x, :decimal
    field :y, :decimal
    field :path, :string
    field :tag_name, :string
    ## Device Types:
    # 0 => Desktop
    # 1 => Tablet
    # 2 => Mobile
    field :device, :integer

    belongs_to :branch, Branch
    has_many :clicks, Click

    timestamps()
  end

  def changeset(element, params \\ %{}) do
    element
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end

  # GET OR FIND OR CREATE
  def get_or_store(branch, snapshot, payload) do
    key = generate_key(snapshot, branch, payload["element"])
    IO.inspect(key)
    find_attrs = [:website_id, :css_path]

    create_attrs = %{
      width: payload["element"]["width"],
      height: payload["element"]["height"],
      top: payload["element"]["top"],
      right: payload["element"]["right"],
      bottom: payload["element"]["bottom"],
      left: payload["element"]["left"],
      device: payload["metadata"]["device"],
      x: payload["element"]["x"],
      y: payload["element"]["y"],
      path: payload["element"]["path"],
      tag_name: payload["element"]["tag_name"]
    }

    element = ConCache.get(:talio_elements_cache, key)
    IO.inspect("ELEMENT")
    IO.inspect(element)

    if element === nil do
      new_element = find_or_create(branch, find_attrs, create_attrs)

      ConCache.put(:talio_elements_cache, key, fn ->
        new_element
      end)
    else
      element
    end
  end

  def find_or_create(branch, find_attrs \\ [], create_attrs \\ %{}) do
    filters = Map.take(create_attrs, find_attrs) |> Map.to_list()

    query =
      from(b in Element,
        where: ^filters,
        join: website in Website,
        on: website.id == ^branch.website_id
      )

    element = Repo.one(query)

    if is_nil(element) do
      %Element{}
      |> changeset(create_attrs)
      |> put_assoc(:branch, branch)
      |> Repo.insert!()
    else
      element
    end
  end

  defp generate_key(snapshot, branch, element) do
    "#{snapshot.website_id}-#{branch.fingerprint}-#{:erlang.phash2(element["path"])}"
  end

  def type!(type) do
    @device_types[type]
  end
end
