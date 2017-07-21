defmodule CodeCorps.PasswordResetView do
  use CodeCorps.Web, :view

  def render("show.json", %{email: email, token: token, user_id: user_id}) do
    %{
      email: email,
      token: token,
      user_id: user_id
    }
  end

end
