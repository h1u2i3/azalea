defmodule Azalea.Type.EctoType do
  @moduledoc """
  The Ecto type to work with ecto.
  """
  defstruct [:files]

  @doc """
  Return from the database, should be a `MapSet`
  """
  def new(files) when is_list(files) do
    struct(__MODULE__, %{files: files})
  end

  defmacro __using__(_opts) do
    quote do
      alias Plug.Upload, as: U
      alias Azalea.Type.EctoType
      alias Azalea.Type.BaseType

      @behaviour Ecto.Type

      def type, do: :text

      # check with the file and dispatch to the right result
      def cast(%EctoType{} = type), do: cast_ecto_type(type)
      def cast(file) when is_map(file), do: file |> List.wrap |> cast
      def cast(files) when is_list(files), do: cast_mutiply_file(files)
      def cast(_), do: :error

      defp cast_mutiply_file(files) do
        if files == [] do
          {:ok, []}
        else
          check_result =
            files
            |> Enum.map(&file_valid?/1)
            |> Enum.all?

          case check_result do
            true ->
              result = files |> do_cast |> List.wrap
              case result do
                :error -> :error
                _ -> {:ok, result}
              end

            false -> :error
          end
        end
      end

      defp cast_ecto_type(type) do
        {:ok, type.files}
      end

      defp file_valid?(file) do
        file
        |> Azalea.File.cast_file
        |> __MODULE__.check
        |> Azalea.File.valid?
      end

      # load from database
      def load(string) when is_binary(string) do
        lists = Code.eval_string(string) |> elem(0)
        {:ok, EctoType.new(lists)}
      end

      def load(_), do: :error

      # dump into databse
      def dump(files) when is_list(files) do
        {:ok, Macro.to_string(files)}
      end

      def demp(_), do: :error

      # cast with the flow
      defp do_cast(files)
      defp do_cast(files) when is_list(files) do
        results = files |> Enum.map(&do_cast/1)
        case Enum.any?(results, &(&1 == :error)) do
          true -> :error
          false -> results
        end
      end
      defp do_cast(file) do
        file |> __MODULE__.handle |> cast_result
      end

      # cast the result of handle
      defp cast_result(result) do
        case result do
          {:error, _reason} -> :error
          _ -> result
        end
      end

    end
  end
end
