defmodule Azalea.File do
  @moduledoc """
  The file struct need for this module.

    * filename, the file's name of the file
    * type, the file's content type, eg: :jpg, :png, :gif
    * path, the file's path in disk or the key in the cloud
    * valid, check if the file is valid
    * uploader, the uploader of the file, normally is local or other uploader handler
    * module, the module you defined to perform all the operation
    * url, the url path of the file, you can get the file through this
  """

  alias Elixir.File, as: F
  alias Azalea.File, as: AF

  defstruct filename: nil, type: nil, path: nil, valid: true,
            uploader: nil, module: nil, url: nil

  @doc """
  Cast from other struct, include Map, Plug.Upload, Ecto.Changeset

    * params  struct of the  file you want to convert
    * field  optional key for you to define which fied of the struct is Azalea.File
  """
  def cast_file(params, field \\ nil)

  def cast_file(%__MODULE__{} = params, _), do: params

  def cast_file(%Ecto.Changeset{} = params, field) do
    from_changeset(params, field)
  end

  def cast_file(%Plug.Upload{} = params, _field) do
    from_plug(params)
  end

  def cast_file(params, _field) when is_map(params) do
    make_struct_from_target(params)
  end

  def cast_file(_, _) do
    empty_struct
  end

  @doc """
  Check if the File struct is empty
  """
  def is_empty?(struct) do
    !struct.filename || !struct.type || !struct.path
  end

  @doc """
  Delete the file data from local disk
  """
  def delete(struct) do
    if struct.path && Elixir.File.exists?(struct.path) do
      Elixir.File.rm_rf!(struct.path)
    end
  end

  @doc """
  Save the file to a new position
  """
  def save(origin, new)
  def save(%AF{valid: false}, _new) do
    :error
  end
  def save(origin, new) do
    if origin.path && F.exists?(origin.path) do
      dir_name = new.path |> Path.dirname
      unless F.exists?(dir_name), do: F.mkdir_p!(dir_name)

      case F.cp(origin.path, new.path) do
        :ok         -> :ok
        {:error, _} -> :error
      end
    else
      :error
    end
  end

  defp from_plug(struct) do
    %AF{empty_struct | type: get_file_type(struct.content_type),
          filename: struct.filename, path: struct.path}
  end

  defp from_changeset(struct, field) do
    plug_upload = struct |> Ecto.Changeset.get_change(field)
    from_plug(plug_upload)
  end

  defp empty_struct do
    %AF{}
  end

  defp make_struct_from_target(struct)
  defp make_struct_from_target(struct) when is_map(struct) do
    case struct do
      %{file: path, type: type} ->
        struct(AF, %{type: type,
                     filename: Path.basename(path),
                     path: path })
      _ ->
        empty_struct
    end
  end
  defp make_struct_from_target(_), do: empty_struct

  defp get_file_type(content_type) do
    type =
      content_type
      |> Plug.Conn.Utils.media_type
      |> elem(2)
      |> String.to_atom
    type = if type == :jpeg, do: :jpg
    type
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
    end
  end
end
