defmodule Azalea.Tool.Fetcher do
  @moduledoc """
  The tool to operate the upload files
  """
  alias Azalea.Type.EctoType
  alias Azalea.Type.BaseType

  @doc """
  Get url from the Azalea.Type.EctoType
  """
  def url(struct, key \\ :main) when is_atom(key) do
    cond do
      %EctoType{} = struct ->
        result = struct.files |> Enum.map(&BaseType.url(&1, key))
        cond do
          is_list(result) && length(result) == 1 ->
            result |> List.first
          is_list(result) ->
            result
          true -> nil
        end

      true -> nil
    end
  end

  @doc """
  Get url from Azalea.Type.EctoType with key and index
  """
  def url_at_index(struct, key \\ :main, index)
              when is_integer(index) and is_atom(key) do
    result = url(struct, key)
    if is_list(result) do
      result |> get_in([Access.at(index)])
    else
      nil
    end
  end
end
