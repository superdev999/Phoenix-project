defmodule CodeCorps.SluggedRouteView do
  use CodeCorps.PreloadHelpers, default_preloads: [:organization, :user]
  use CodeCorps.Web, :view
  use JaSerializer.PhoenixView

  attributes [:slug, :inserted_at, :updated_at]

  has_one :organization, serializer: CodeCorps.OrganizationView
  has_one :user, serializer: CodeCorps.UserView
end
