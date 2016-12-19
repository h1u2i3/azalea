defmodule Azalea.TestCase do
  @moduledoc """
  Test method with Azalea
  """

  alias Plug.Upload, as: U

  @doc """
  Make a test upload file.
  """
  def make_file(filename, path, type) do
    %U{
      filename: filename,
      content_type: type,
      path: path
    }
  end
end
