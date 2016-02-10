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
#      REVISION:  2016-02-10 15:26
#===============================================================================

cd ~/Downloads/tennis_atp-master

# the file generated is used only by tennis.sh which is superceded by t.sh

cut -d, -f11,21 atp_matches_*.csv | tr ',' '\n' | sort -u > players.list
wc -l players.list
