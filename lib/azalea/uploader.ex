defmodule Azalea.Uploader do
  @moduledoc """
  The common methods needed for upload file
  """

  @doc """
  Upload file with the user specify
  """
  def upload(file, uploader, options) do
    apply(uploader, :upload, [file, options])
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
    end
  end

end
