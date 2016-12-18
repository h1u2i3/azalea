defmodule Azalea do
  @moduledoc """
  Azalea contains the needed mthods to
  to do all the check/upload/work.
  You can use like this:

      defmodule Demo.Avatar do
        use Azalea
      end
  """

  defmacro __using__(_opts) do
    quote do
      use Azalea.File
      use Azalea.Checker
      use Azalea.Handler
      use Azalea.Uploader
      use Azalea.EctoType

      @before_compile Azalea.Handler
    end
  end
end
