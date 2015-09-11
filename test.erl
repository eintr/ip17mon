#!/usr/local/bin/escript

main(_) ->
	{ok, H} = ip17mon:load("17monipdb.dat"),
	{V1,V2,V3,V4} = ip17mon:lookup("202.108.196.115", H),	%{Country, Region, City, ISP}
	io:format("Country=~s\tRegion=~s\tCity=~s\tISP=~s\n", [V1,V2,V3,V4]),
	ok.

