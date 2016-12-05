defmodule Azalea.Uploader.Crypto do
  @moduledoc """
  Crypto Helper methods.
  """

  def sha_mac(string, secret) do
    :sha
    |> :crypto.hmac(secret, string)
  end

  def url_base64(string) do
    string |> Base.url_encode64
  end


end
