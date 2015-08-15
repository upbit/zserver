ZServer
--------------------

A simple web server written in Elixir.

## How-To

1. `git clone https://github.com/upbit/zserver.git`
1. `mix deps.get && mix deps.compile`
1. Dev: `iex -S mix`
1. Release: `MIX_ENV=prod mix release`

## To-Do

* [x] A web server framework written in Elixir
* [x] ~~Support [maru](https://github.com/falood/maru)/[maru_swagger](https://github.com/falood/maru_swagger)~~
* [x] Handling 40x/500 error in routers
* [x] Add [exsync](https://github.com/falood/exsync) in server for code reload
* [ ] Release project NekoNail, a illusts/ranking spider of pixiv.net
* [ ] Support similarity illust search use ElasticSearch
