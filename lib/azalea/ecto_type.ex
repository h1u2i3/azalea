defmodule Azalea.EctoType do
  defmacro __using__(_opts) do
    quote do
      @behaviour Ecto.Type

      alias Azalea.File, as: AF

      def type, do: :text

      def cast(files, result \\ [])
      def cast(%Plug.Upload{} = file, _result) do
        {:ok, __MODULE__.handle(file)}
      end
      def cast([], result), do: {:ok, result}
      def cast([%Plug.Upload{} = hd | tl], result) do
        cast(tl, result ++ [__MODULE__.handle(hd)])
      end
      def cast([%{} = hd | tl], result) do
        cast(tl, result ++ [__MODULE__.handle(hd)])
      end
      def cast([_ | tl], result) do
        cast(tl, result ++ [:error])
      end
      def cast(_, _), do: :error

      # load from database
      def load(string) when is_binary(string) do
        {:ok, Code.eval_string(string) |> elem(0)}
      end
      def load(_), do: :error

      # dump into databse
      def dump(list) when is_list(list) do
        {:ok, Macro.to_string(list)}
      end
      def dump(_), do: :error
    end
  end
end
