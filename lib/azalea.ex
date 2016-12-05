defmodule Azalea do
  @moduledoc """
  Azalea contains the needed mthods to generate the dynamic module
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

      @before_compile Azalea.Handler


      # Generate the dynamic module name to use as the definition module
      # to deal with the checker/uploader/worker.
      def get_dynamic_module_name_list do
        [Azalea, Auto, __MODULE__]
      end
    end
  end
end
