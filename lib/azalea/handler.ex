defmodule Azalea.Handler do
  @moduledoc """
  Define the handler to do some job.
  eg:
    - use imagemagick to compress picture.
    - compress the video
    - add watermark to your picture
  """
  alias Azalea.File, as: AF

  @doc """
  Add the handler macro method
  """
  defmacro handler(key \\ :main, do: block) do
    call_string = Macro.to_string(block)
    quote do
      Module.put_attribute __MODULE__, :calls, unquote({key, call_string})
    end
  end

  defmacro __before_compile__(env) do
    # [main: "(\n  name(:mini)\n  upload(Azalea.Uploader.Local, path:
    # [local_root, \"avatar\"])\n)"]

    calls =
      env.module
      |> Module.get_attribute(:calls)
      |> Enum.map(fn({key, value}) ->
           {key, handler_string(value)}
         end)

    keys = Keyword.keys(calls)

    method_string = """
    def handle(struct) do
      file = struct |> cast |> check
      file = %{file | module: #{env.module}}
      Enum.map(#{Macro.to_string(keys)}, &do_handler(file, &1))
    end

    defp do_handler(file, key)
    #{handler_method_string(calls)}
    """

    Code.eval_string(method_string, [], env)
  end

  defp handler_method_string(calls) do
    for {key, value} <- calls do
      """
      defp do_handler(file, #{Macro.to_string(key)}) do
        #{value}
      end
      """
    end |> Enum.join("\n")
  end

  defp handler_string(value) do
    ~r/\b(?:.*)\B/
    |> Regex.scan(value)
    |> List.flatten
    |> List.insert_at(0, "file")
    |> Enum.join(" |> ")
  end


  @doc """
  The background system cmd to do with the File struct
  """
  def system(file, cmd, args)
  def system(%AF{valid: false} = file, _, _), do: file
  def system(file, cmd, args) do
    old_path = file.path
    new_path = Path.join [System.tmp_dir!, file.filename]
    args = [old_path] ++ args ++ [new_path]

    case System.cmd(cmd, args) do
      {_, 0} -> %{file | path: new_path}
      {_, 1} -> raise "Cmd error, check with your command"
    end
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      Module.register_attribute __MODULE__, :calls, accumulate: true

      @doc """
      Change the name fo the File struct
      """
      def name(file, kind) do
        %{file | filename: "#{name(kind)}.#{file.type}"}
      end
    end
  end
end
