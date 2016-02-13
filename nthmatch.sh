#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: nthmatch.sh
# 
#         USAGE: ./nthmatch.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 02/13/2016 15:23
#      REVISION:  2016-02-13 15:38
#===============================================================================

if [  $# -eq 0 ]; then
    echo "Please pass full name and how many matches from first match of a player"
    exit 1
fi
name="$1"
limit=${2:-100}
if [[ -z "$name" ]]; then
    echo -e "Please pass name." 1<&2
    exit 1
fi
sqlite3 tennis.db <<! | nl
.mode tabs
select tourney_name, match_num as num, round, winner_name, loser_name, tourney_date, cast(winner_age as int) as w_age, cast(loser_age as int)  as l_age from matches where winner_name = "${name}" or loser_name = "${name}" order by tourney_date, cast(match_num as int) limit ${limit};
!
