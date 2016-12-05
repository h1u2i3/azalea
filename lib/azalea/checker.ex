defmodule Azalea.Checker do
  @moduledoc """
  Check with the file that already uploaded.
  Or just check the remote url to make sure get the safe data.
  """

  @doc """
  Use to build the check method for check file
  """
  defmacro checker(do: block) do
    quote do
      unquote(block)
    end
  end

  @doc """
  User to set the types in checker builder

      type allow: [:jpg, jpeg, :png, :gif]
      type execpt: [:text]
  """
  defmacro type(types) do
    quote do
      defp validate_type(file) do
        case file do
          %Azalea.File{} ->
            %Azalea.File{file | valid: file_type_in?(file, unquote(types))}
          _ -> file
        end
      end
    end
  end

  @doc """
  User to set the file size in checker builder
  size unit: kb

      size min: 100, max: 10000
  """
  defmacro size(range) do
    quote do
      defp validate_size(file) do
        case file do
          %Azalea.File{} ->
            %Azalea.File{file | valid: file_size_in?(file, unquote(range))}
          _ -> file
        end
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      import Ecto.Changeset, only: [get_change: 2, validate_change: 3]

      @doc """
      Just check with the given `Azalea.File`,
      it will be valid by default.
      """
      def check(file) do
        file
        |> validate_empty
        |> validate_type
        |> validate_size
      end

      @doc """
      Validate method for use with ecto.
      """
      def validate_upload(changeset, field) do
        value = changeset |> get_change(field)
        case value do
          nil -> changeset
          _ ->
            require Logger
            Logger.info inspect(value)
            if length(value) == 0 do
              validate_change(changeset, field, fn(_, _) ->
                [{field, "Upload file invalid!"}]
              end)
            else
              changeset
            end
        end
      end

      defp file_type_in?(file, types) do
        allow = types[:allow] || []
        except = types[:except] || []
        (file.type in allow) || !(file.type in except)
      end

      defp file_size_in?(file, range) do
        if file.path && File.exists?(file.path) do
          size_in_kb = File.stat!(file.path).size |> div(1000)
          size_in_kb = if size_in_kb === 0, do: 1, else: size_in_kb

          range = range |> Keyword.take([:min, :max]) |> Keyword.values
          size_in_kb in Enum.min(range)..Enum.max(range)
        else
          false
        end
      end

      defp validate_empty(file) do
        case file do
          %Azalea.File{} ->
            if Azalea.File.is_empty?(file) do
              %Azalea.File{file | valid: false}
            else
              file
            end
          _ -> file
        end
      end

      defp validate_size(file), do: file
      defp validate_type(file), do: file

      # make the check method overridable
      defoverridable [check: 1, validate_size: 1, validate_type: 1]
    end
  end
end
