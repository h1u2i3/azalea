defmodule Azalea.EctoType do
  defmacro __using__(_opts) do
    quote do
      @behaviour Ecto.Type

      def type, do: :text

      # cast from Plug.Upload to Azalea.File
      def cast(files) do
        result =
          files
          |> _cast([])
          |> Enum.reject(&(length(&1) == 0))

        if result == :error do
          :error
        else
          {:ok, result}
        end
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

      defp _cast(files, result)
      defp _cast(%Plug.Upload{} = file, _result) do
        [file |> __MODULE__.handle]
      end
      defp _cast([], result), do: result
      defp _cast([%Plug.Upload{} = file | tail], result) do
        _cast(tail, result ++ [__MODULE__.handle(file)])
      end
      defp _cast([%{} = file | tail], result) do
        _cast(tail, result ++ [__MODULE__.handle(file)])
      end
      defp _cast([_ | tail], result) do
        _cast(tail, result ++ [:error])
      end
      defp _cast(_, _), do: :error
    end
  end
end
