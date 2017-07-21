defmodule CodeCorps.Services.MarkdownRendererService do
  @moduledoc """
  Used to render provided markdown into html using an external renderer package.
  """

  alias Ecto.Changeset

  @spec render_markdown_to_html(Changeset.t, atom, atom) :: Changeset.t
  def render_markdown_to_html(%Changeset{valid?: false} = changeset, _, _), do: changeset
  def render_markdown_to_html(changeset, source_field, destination_field) do
    case Changeset.get_change(changeset, source_field) do
      "" -> Changeset.put_change(changeset, destination_field, nil)
      nil -> changeset
      markdown -> markdown |> convert_into_html() |> put_into(changeset, destination_field)
    end
  end

  @spec convert_into_html(String.t) :: String.t
  defp convert_into_html(markdown) do
    # Prism.js requires a `language-` prefix in code classes
    # See: https://github.com/pragdave/earmark#syntax-highlightning
    Earmark.as_html!(markdown, %Earmark.Options{code_class_prefix: "language-"})
  end

  @spec put_into(String.t, Changeset.t, atom) :: Changeset.t
  defp put_into(html, changeset, destination_field) do
    Changeset.put_change(changeset, destination_field, html)
  end
end
