defmodule Azalea.Tool.Http do
  @moduledoc """
  Make http request
  """
  def post(url, body) do
    ensure_httpoison_started
    headers = [{"Content-Type", "multipart/form-data"}]
    url |> HTTPoison.post(body, headers)
  end

  defp ensure_httpoison_started do
    Application.ensure_all_started(:httpoison)
  end
end
