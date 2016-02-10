# tennis-atp
programs to query Jeff Sackmann excellent tennis CSV files
https://github.com/JeffSackmann/tennis_atp
(You could press download zip and then expand into a directory, or clone it)


For these program to work you require:

- downloaded copy of Jeff Sackmann's tennis-atp-masters csv files from github
https://github.com/JeffSackmann/tennis_atp
- sqlite3
  Import all the files using the convert program
- bash
- fzf (some programs use this for fuzzy selection of names and events. fzf depends on `go`
  and can be installed on OSX as `brew install fzf`.

- csvlook - some programs use csvlook ( a python program that creates table taking the output).
  This can be installed using `pip`. If you don't want this dependency you can replace this
  with the columns command. Use the --raw flag to avoid calling `csvlook`
