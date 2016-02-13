# tennis-atp

programs to query Jeff Sackmann excellent tennis CSV files
https://github.com/JeffSackmann/tennis_atp
(You could press "download zip" and then expand into a directory, or clone it)


For these program to work you require:

- downloaded copy of Jeff Sackmann's tennis-atp-masters csv files from github
https://github.com/JeffSackmann/tennis_atp
- sqlite3
  Import all the files using the convert_sqlite.sh program provided by Jeff. Pass
  "tennis.db" as the argument.
- bash
- fzf (some programs use this for fuzzy selection of names and events. fzf depends on `go`
  and can be installed on OSX as `brew install fzf`.

- csvlook - some programs use csvlook ( a python program that creates table taking the output).
  This can be installed using `pip`. If you don't want this dependency you can replace this
  with the columns command. Use the --raw flag to avoid calling `csvlook`

Use t.sh for most of your queries. It uses the database.
(tennis.sh is the older version which uses the flat files and gets quite complicated since
filtering on specific fields in a CSV is possible, but not easy). SQL is much easier.

try h2h.sh but it's functionality is largely there in t.sh.

t.sh --help to see options and examples of usage.


## TODO

Some fields may need to be changed to int. Otherwise they don't sort correctly. Such as match_num.
Check age too.
