defmodule Azalea.Tool.TestCase do
  @moduledoc """
  Test method with Azalea
  """
  alias Azalea.Type.EctoType
  alias Azalea.Type.BaseType
  alias Plug.Upload

  @doc """
  Make a test EctoType file without go through all the upload workflow.
  Just to make the test go easy.
  Ecto.Changeset.cast %Site.User{}, %{photo: Azalea.Tool.TestCase.make_file(:jpg, :remote)}, [:photo]
  """
  def make_file(type, url, key \\ :main) do
    # generate a random file from Plug.Upload
    temp = Upload.random_file!("azalea")

    file =
      %Azalea.File{
        filename: Path.basename(temp),
        key: key,
        type: type,
        path: temp,
        module: __MODULE__,
        uploader: Azalea.Uploader.Local,
        url: url,
        valid: true
      }

    %EctoType{ files: [
      %BaseType{ files: [{key, file}] }
    ]}
  end
end
