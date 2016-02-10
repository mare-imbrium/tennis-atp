#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: create_players_list.sh
# 
#         USAGE: ./create_players_list.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 02/07/2016 11:21
#      REVISION:  2016-02-07 11:23
#===============================================================================

cut -d, -f11,21 atp_matches_*.csv | tr ',' '\n' | sort -u > players.list
wc -l players.list
