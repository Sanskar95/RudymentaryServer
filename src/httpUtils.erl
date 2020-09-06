
-module(httpUtils).
-export([parseHttpRequest/1, success/1, get/1]).

success(Body) ->
	"HTTP/1.1 200 OK\r\n" ++ "\r\n" ++ Body.

get(URI) ->
	"GET " ++ URI ++ " HTTP/1.1\r\n" ++ "\r\n".

parseHttpRequest(R0) ->
	{Request, R1} = getRequestLine(R0),
	{Headers, R2} = getHttpHeaders(R1),
	{Body, _}  = getMessageBody(R2),
	{Request, Headers, Body}.

getRequestLine([$G, $E, $T, 32 |R0]) ->
	{URI, R1} = getUri(R0),
	{Ver, R2} = getHttpVersion(R1),
	[13,10|R3] = R2,
	{{get, URI, Ver}, R3}.

getUri([32|R0]) ->
	{[], R0};
getUri([C|R0]) ->
	{Rest, R1} = getUri(R0),
	{[C|Rest], R1}.

getHttpVersion([$H, $T, $T, $P, $/, $1, $., $1 | R0]) ->
	{v11, R0};
getHttpVersion([$H, $T, $T, $P, $/, $1, $., $0 | R0]) ->
	{v10, R0}.

getHttpHeaders([13,10|R0]) ->
	{[],R0};
getHttpHeaders(R0) ->
	{Header, R1} = getHeader(R0),
	{Rest, R2} = getHttpHeaders(R1),
	{[Header|Rest],R2}.

getHeader([13,10|R0]) ->
	{[],R0};

getHeader([C|R0]) ->
	{Rest, R1} = getHeader(R0),
	{[C|Rest],R1}.

getMessageBody(R) ->
	{R, []}.
