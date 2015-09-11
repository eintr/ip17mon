-module(ip17mon).

-export([load/1, lookup/2]).

load(Filename) ->
	{ok, Bin} = file:read_file(Filename),
	<<Offset:32/unsigned-big-integer, Byte0Index:1024/binary, T/binary>> = Bin,
	IPIndSize = Offset-1024-4-1024,	% A magic, I just followed the official php source code.
	<<IPIndex:IPIndSize/binary, Data/binary>> = T,
	{ok, {Byte0Index, IPIndex, Data, ets:new(ip17mon_cache, [set, public])}}.

lookup(IpAddr, {Byte0Index, IPIndex, Data, Cache}) when is_list(IpAddr) ->
	{ok, {A, _, _, _}=IP} = inet:parse_ipv4_address(IpAddr),
	case ets:lookup(Cache, IP) of
		[] ->
			<<Index:32/unsigned-little-integer>> = binary:part(Byte0Index, A*4, 4),
			Skip = Index*8,
			<<_:Skip/binary, Subset/binary>> = IPIndex,
			Value = case match(inetaton(IP), Subset) of
				na -> {"Unknown", "Unknown", "Unknown", "Unknown"};
				{Offset, Len} ->
					list_to_tuple(
					  lists:map(
						fun binary:bin_to_list/1,
						binary:split(binary:part(Data, Offset, Len), <<9>>, [global]))) % 9 is '\t'
			end,
			ets:insert(Cache, {IP, Value}),
			Value;
		[{IP, Value}] -> Value
	end.

inetaton({A, B, C, D}) ->
	D+C*256+B*256*256+A*256*256*256.

match(_, <<>>) -> io:format("Empty index.\n"), na;
match(N, <<Start:32/unsigned-big-integer, _Offset:24/unsigned-little-integer, _Len:8/unsigned-little-integer, Rest/binary>>) when Start < N ->
	match(N, Rest);
match(N, << Start:32/unsigned-big-integer, Offset:24/unsigned-little-integer, Len:8/unsigned-little-integer, _/binary>>) when Start >= N ->
	{Offset, Len}.

