-module(rudy).

-export([init/1, start/1, stop/0]).

init(Port) ->
  Opt = [list, {active, false}, {reuseaddr, true}],
  case gen_tcp:listen(Port, Opt) of
    {ok, Listen} ->
      handler(Listen),

      gen_tcp:close(Listen),
      ok;
    {error, Error} ->
      error
  end.

handler(Listen) ->
  case gen_tcp:accept(Listen) of
    {ok, Client} ->
      request(Client),
      handler(Listen);
    {error, Error} ->
      error
  end.

request(Client) ->
  Recv = gen_tcp:recv(Client, 0),
  case Recv of
    {ok, Str} ->
      Request = httpUtils:parseHttpRequest(Str),
      Response = reply(Request),
      gen_tcp:send(Client, Response);
    {error, Error} ->
      error
  end,
  gen_tcp:close(Client).

reply({{get, URI, _}, _, _}) ->
  case file:read_file("www/succesas.html") of
    {ok, File}-> httpUtils:success(File);
    {error,Error}->replyWithFailure()
  end.

replyWithFailure()->
  {ok, File} = file:read_file("www/failure.html"),
  httpUtils:success(File).


start(Port) ->
  register(rudy, spawn(fun() -> init(Port) end)).
stop() ->
  exit(whereis(rudy), "time to die").

