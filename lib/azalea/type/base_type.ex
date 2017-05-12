defmodule Azalea.Type.BaseType do
  @moduledoc """
  The methods to get the info from
  """
  defstruct [:files]

  @doc """
  Build the mutiply files into type
  """
  def cast(files) when is_list(files) do
    if files == [] do
      {:error, :empty}
    else
      %{ empty_struct() | files: build_files(files) }
    end
  end

  @doc """
  Get file from struct base on the key
  """
  def file(%__MODULE__{} = struct, key \\ :main) do
    struct.files[key]
  end

  @doc """
  Generate the urls for the struct
  """
  def url(%__MODULE__{} = struct) do
    struct.files |> Enum.map(fn({key, file}) ->
      {key, file.url}
    end)
  end

  @doc """
  Get the url with the specific key
  """
  def url(%__MODULE__{} = struct, key) do
    file = struct.files[key]
    case file do
      nil -> nil
      _ -> file.url
    end
  end

  defp build_files(files) do
    files |> Enum.map(&{&1.key, &1})
  end

  defp empty_struct do
    %__MODULE__{}
  end
end
