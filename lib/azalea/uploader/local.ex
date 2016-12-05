defmodule Azalea.Uploader.Local do
  @moduledoc """
  Upload file to local disk
  """
  alias Azalea.File, as: AF

  @doc """
  Save file to local disk.
  And then delete the origin file.
  """
  def upload(file, options) do
    root = options[:base_path] || raise "You did not set the local save path"
    root_url = options[:base_url] || raise "You did not set the url base url"

    kind = options[:kind] || :main
    path = Path.join(root, "#{file.filename}")
    url = root_url <> "/" <> file.filename

    new_file = %{file | path: path, uploader: __MODULE__}

    try do
      case AF.save(file, new_file) do
        :ok -> {kind, %{new_file | url: url}}
        _   -> {kind, {:error, :save_failed}}
      end
    after
      AF.delete(file)
    end
  end
end
