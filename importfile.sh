#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: importfile.sh
# 
#         USAGE: ./importfile.sh 
# 
#   DESCRIPTION: import a single atp file. Used when data has been updated.
# 
#       OPTIONS: year needs to be specified
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 02/08/2016 12:51
#      REVISION:  2016-02-08 12:59
#===============================================================================

if [  $# -eq 0 ]; then
    echo "Please give year"
    exit 1
else
    YEAR=$1
fi
INFILE=./atp_matches_${YEAR}.csv
if [[ ! -f "$INFILE" ]]; then
    echo "File: $INFILE not found" 1<&2
    exit 1
else
    wc -l $INFILE
fi
SQLITE=$(brew --prefix sqlite)/bin/sqlite3
MYDATABASE=tennis.db
MYTABLE=matches
MYCOL=yyy
$SQLITE $MYDATABASE <<!
select count(*) from $MYTABLE ;
select count(*) from $MYTABLE where tourney_date like "${YEAR}%";
!
echo proceeding to delete for the year $YEAR. Press ENTER
read
$SQLITE $MYDATABASE <<!
DELETE from $MYTABLE WHERE tourney_date LIKE "${YEAR}%";
select count(*) from $MYTABLE ;
select count(*) from $MYTABLE where tourney_date like "${YEAR}%";
!
echo Deleted Rows for $YEAR
echo Importing from $INFILE into $MYTABLE
$SQLITE $MYDATABASE <<!
.mode csv
.headers on
.import $INFILE $MYTABLE
!
echo Imported
$SQLITE $MYDATABASE <<!
select count(*) from $MYTABLE ;
select count(*) from $MYTABLE where tourney_date like "${YEAR}%";
!
