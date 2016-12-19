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
      def cast(file) do
        cond do
          is_binary(file) -> :error
          is_atom(file) -> :error
          is_map(file) -> do_cast(file)
          %U{} = file -> do_cast(file)
        end
      end

      # cast from Plug.Upload to Azalea.File
      defp do_cast(file) do
        result =
          file
          |> _cast([])
          |> Enum.reject(&(length(&1) == 0))

        if result == :error do
          :error
        else
          {:ok, result}
        end
      end

      # cast with the flow
      defp _cast(files, result)

      defp _cast([], result), do: result

      defp _cast(%U{} = file, _result) do
        [file |> __MODULE__.handle]
      end

      defp _cast([%U{} = file | tail], result) do
        _cast(tail, result ++ [__MODULE__.handle(file)])
      end

      defp _cast([%{} = file | tail], result) do
        _cast(tail, result ++ [__MODULE__.handle(file)])
      end

      defp _cast([_ | tail], result) do
        _cast(tail, result ++ [:error])
      end

      defp _cast(_, _), do: :error

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
    end
  end
end
