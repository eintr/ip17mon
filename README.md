# ip17mon

A simple erlang module to decode ip database from ipip.net

## Module
exported: load/1 lookup/2

    load(17MONIPDB_FILE_NAME) -> {ok, CONTEXT}

      17MONIPDB_FILE_NAME = list()



    lookup(IPADDRESS, CONTEXT) -> {COUNTRY, REGION, CITY, ISP}

      IPADDRESS = list()

## Example
test.erl is an example:

    {ok, H} = ip17mon:load("17monipdb.dat"),
    {V1,V2,V3,V4} = ip17mon:lookup("202.108.196.115", H),
    io:format("Country=~s\tRegion=~s\tCity=~s\tISP=~s\n", [V1,V2,V3,V4]),
    ok.

