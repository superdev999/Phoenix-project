defmodule CodeCorps.GitHub.Event.Installation.MatchedUser do
  @moduledoc """
  In charge of handling the matched user case of an installation event
  """

  import Ecto.Query

  alias CodeCorps.{GithubAppInstallation, Repo, User}
  alias Ecto.Changeset

  @typep process_outcome :: {:ok, GithubAppInstallation.t} | {:error, Changeset.t}
  @typep outcome :: process_outcome | {:error, :too_many_unprocessed_installations}

  @doc """
  Handles the installation event in the case of a matched user.

  This is done by attempting to find a `GithubAppInstallation` record belonging
  to the matched user, with a blank `github_id` field.

  If no records are found, this means the installation was done from GitHub
  directly and it just so happens we have a connected GitHub user on record
  who performed the installation.

  If a record is found, then we update it's `github_id` field and then fetch
  repositories for that installation and store them locally.

  The case of multiple records being found should not be possible and results
  in an error tuple being returned.
  """
  @spec handle(map, User.t) :: outcome
  def handle(%User{} = user, %{} = installation_attrs) do
    case user |> find_unprocessed_installations() do
      [] -> user |> create_installation(installation_attrs)
      [%GithubAppInstallation{} = installation] -> update_installation(installation, installation_attrs)
      [_|_] -> {:error, :too_many_unprocessed_installations}
    end
  end

  @spec find_unprocessed_installations(User.t) :: list(GithubAppInstallation.t)
  defp find_unprocessed_installations(%User{id: user_id}) do
    GithubAppInstallation
    |> where([i], is_nil(i.github_id) and i.user_id == ^user_id)
    |> preload(:github_repos)
    |> Repo.all
  end

  @spec create_installation(User.t, map) :: process_outcome
  defp create_installation(%User{github_id: sender_github_id} = user, %{"id" => github_id}) do
    attrs = %{
      github_id: github_id,
      sender_github_id: sender_github_id,
      installed: true,
      origin: "github"
    }

    %GithubAppInstallation{}
    |> changeset(attrs)
    |> Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @spec update_installation(GithubAppInstallation.t, map) :: process_outcome
  defp update_installation(%GithubAppInstallation{} = installation, %{"id" => github_id}) do
    attrs = %{github_id: github_id, installed: true}
    installation |> changeset(attrs) |> Repo.update()
  end

  defp changeset(%GithubAppInstallation{} = installation, %{} = attrs) do
    installation
    |> Changeset.change(attrs)
    |> Changeset.unique_constraint(:github_id, name: :github_app_installations_github_id_index)
  end
end
