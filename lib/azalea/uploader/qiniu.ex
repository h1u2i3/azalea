defmodule Azalea.Uploader.Qiniu do
  @moduledoc """
  File uploader for Qiniu
  """
  require IEx
  import Azalea.Uploader.Crypto
  import Azalea.Http

  alias Azalea.File, as: AF

  @upload_url "http://upload.qiniu.com"
  @resource_url "http://ohnslot2o.bkt.clouddn.com"

  def upload(file, options)

  def upload(%AF{valid: false}, options) do
    kind = options[:kind] || :main
    {kind, {:error, :file_invalid}}
  end

  def upload(file, options) do
    scope = options[:scope] || raise "You did not set the Qiniu scope"
    base_path = options[:base_path] || ""
    kind = options[:kind] || :main

    filename = file.filename
    filekey = "#{base_path}/#{filename}"
    path = file.path

    strategy = build_strategy(scope, filekey)
    upload_token = build_upload_token(strategy)

    {:ok, response} =
      post(@upload_url, {:multipart, [{"token", upload_token},
        {"file", filename}, {"key", filekey}, {:file, path}]})

    body = Poison.decode!(response.body, keys: :atoms)

    case body do
      %{hash: _, key: key} ->
        {kind, %{file | url: url_from_key(key),
          uploader: __MODULE__, path: key}}
      %{error: reason}  ->
        {kind, reason}
    end

  end


  defp build_strategy(scope, filekey) do
    strategy_map = %{ scope: "#{scope}:#{filekey}",
                      deadline: System.os_time(:seconds) + 3600,
                      saveKey: filekey}
    Poison.encode!(strategy_map)
  end

  defp build_upload_token(strategy) do
    access_key = config[:access_key]
    secret_key = config[:secret_key]

    encoded_put_policy = strategy |> url_base64
    encoded_sign = encoded_put_policy |> sha_mac(secret_key) |> url_base64

    "#{access_key}:#{encoded_sign}:#{encoded_put_policy}"
  end

  def url_from_key(key) do
    @resource_url <> "/" <> key
  end

  defp config do
    Application.get_env(:azalea, Azalea.Uploader.Qiniu)
  end

end
