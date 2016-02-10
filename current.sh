#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: current.sh
# 
#         USAGE: ./current.sh 
# 
#   DESCRIPTION: import, download or list current rankings
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 02/10/2016 10:55
#      REVISION:  2016-02-10 13:04
#===============================================================================

MYDATABASE=tennis.db
SQLITE=$(brew --prefix sqlite)/bin/sqlite3

download() {
    # download the latest rankings file
curl "https://raw.githubusercontent.com/JeffSackmann/tennis_atp/master/atp_rankings_current.csv" > t.t
wc -l t.t
if [[ ! -s "t.t" ]]; then
    echo "Could not download file, file is empty"
else
    cmp t.t atp_rankings_current.csv
    if [  $? -eq 0 ]; then
        echo "No change in data, existing file is current"
    else
        mv t.t atp_rankings_current.csv
        echo "import to import the data into database"
    fi
fi

}
import() {
    # import into database
    echo "Dropping and recreating table CURRENT"
echo "drop table current ;" | sqlite3 $MYDATABASE
echo "create table current (date,pos INT,player_id INT,pts INT);" | sqlite3 $MYDATABASE

i=./atp_rankings_current.csv
$SQLITE $MYDATABASE << !
.headers off
.mode csv
.import $i current
!

echo "Current Rankings Imported"

echo "Creating Index"
$SQLITE $MYDATABASE << !
create index currentPlayer ON current (player_id);
create index currentPos ON current (pos);
create index currentDate ON current (date);
!
echo "Done"
}
list() {
    # list top 20 or whatever requested"
#echo "inside list"
limit=${1:-20}
$SQLITE $MYDATABASE << !
.mode tabs
select c.date, c.pos, c.pts, p.firstname, p.lastname   from current c, player p where c.player_id = p.id  order by c.date desc ,c.pos limit $limit;
!
}
help() {
    cat << EOF
    $0
        import   import current.csv
        list [n] list top n players for latest week
EOF
}
if [  $# -eq 0 ]; then
    list
    exit 0
fi
if [[ $1 =~ ^(import|help|list|download)$ ]]; then
  "$@"
else
  echo "Invalid subcommand $1" >&2
  exit 1
fi
