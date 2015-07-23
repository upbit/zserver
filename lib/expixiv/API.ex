defmodule ExPixiv.API do
  use Tesla.Builder

  with Tesla.Middleware.BaseUrl, "http://httpbin.org/"
  with Tesla.Middleware.Headers, %{'Referer': 'http://www.pixiv.net/'}
  with Tesla.Middleware.EncodeJson
  with Tesla.Middleware.DecodeJson

  adapter Tesla.Adapter.Ibrowse

  def login(clientusername, password) do
    {:ok, data} = JSX.encode(%{
      'username': username,
      'password': password,
      'grant_type': "password",
      'client_id': "bYGKuGVw91e0NMfPGp44euvGt59s",
      'client_secret': "HP3RmkgAmEGro0gn1x9ioawQE8WMfvLXDz3ZqxpK",
    })
    Tesla.post("http://httpbin.org/post", data)
  end

  def client do
    Tesla.build_client [
      {Tesla.Middleware.Headers, %{'Referer': 'http://www.pixiv.net/'}}
    ]
  end
end