# tennis-atp

programs to query Jeff Sackmann excellent tennis CSV files
https://github.com/JeffSackmann/tennis_atp
(You could press "download zip" and then expand into a directory, or clone it)


For these program to work you require:

- downloaded copy of Jeff Sackmann's tennis-atp-masters csv files from github
https://github.com/JeffSackmann/tennis_atp
(data files are in ~/Downloads/tennis_atp-master/ )
NOW IN /Volumes/Pacino/dziga_backup/rahul/Downloads/tennis_atp-master

When downloading individual files I find that they are gzipped. So we have to gunzip them too.

Currently this was the URL.
wget https://raw.githubusercontent.com/JeffSackmann/tennis_atp/master/atp_matches_2017.csv

Use importfile.sh <2018> for individual years

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

# Update every year or after a few months.
  Download the atp_matches file for that year.
  Call importfile.sh with the year. It will delete data for that year and reinsert that data.

## TODO

Some fields may need to be changed to int. Otherwise they don't sort correctly. Such as match_num.
Check age too.
