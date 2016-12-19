defmodule Azalea.EctoType do
  @moduledoc """
  The Ecto type to work with ecto.
  """

  defmacro __using__(_opts) do
    quote do
      alias Plug.Upload, as: U

      @behaviour Ecto.Type

      def type, do: :text

      # check with the file and dispatch to the right result
      def cast(file) when is_map(file), do: cast_single_file(file)
      def cast(file) when is_list(file), do: cast_mutiply_file(file)
      def cast(_), do: :error

      defp cast_single_file(file) do
        check_result = file |> file_valid?

        case check_result do
          true -> {:ok, __MODULE__.handle(file)}
          false -> :error
        end
      end

      defp cast_mutiply_file(file) do
        check_result =
          file
          |> Enum.map(&file_valid?/1)
          |> Enum.all?

        case check_result do
          true -> {:ok, do_cast(file)}
          false -> :error
        end
      end

      defp file_valid?(file) do
        file
        |> Azalea.File.cast_file
        |> Azalea.File.valid?
      end

      # load from database
      def load(string) when is_binary(string) do
        {:ok, Code.eval_string(string) |> elem(0)}
      end

      def load(_), do: :error

      # dump into databse
      def dump(files) when is_list(files) do
        {:ok, Macro.to_string(files)}
      end

      def demp(_), do: :error

      # cast with the flow
      defp do_cast(files, result \\ [])
      defp do_cast([], result), do: Enum.reverse(result)
      defp do_cast([file | tail], result) do
        do_cast(tail, [__MODULE__.handle(file) | result])
      end
    end
  end
end
