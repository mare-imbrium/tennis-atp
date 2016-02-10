#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: shorten.sh
# 
#         USAGE: ./shorten.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 02/09/2016 19:03
#      REVISION:  2016-02-09 20:07
#===============================================================================

sed 's/Novak //g;
     s/Roger //g;
     s/Rafael //g;
     s/Stanislas //g;
     s/Australian Open/AO/g;
     s/Roland Garros/FO/g;
     s/US Open/USO/g;
     s/Wimbledon/WO/g;
     s/Masters//g;
     s/tourney_name/event/g;
     s/winner_name/winner/g;
     s/loser_name/loser/g;
     '
