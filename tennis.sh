#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: tennis.sh
# 
#         USAGE: ./tennis.sh nadal
#                ./tennis.sh federer nadal
#                ./tennis.sh federer nadal 2012
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 02/05/2016 14:51
#      REVISION:  2016-02-07 15:25
#===============================================================================

# = TODO
# - if a blank is passed on command line for an argument then don't ask, take it as all.
# - matches of some level F SF R16 etc
# - matches a player has won or lost
# x matches against another player
# - only highest round for that player
# x only take slams into account ???
# x there should be another way of doing this so one can do:
#   --player federer --event "US Open" --round "F" --year 2010

cd /Users/rahul/Downloads/tennis_atp-master || exit -1

OPT_VERBOSE=
OPT_DEBUG=
while [[ $1 = -* ]]; do
    case "$1" in
        -p|--player)   shift
            PRO=$1
            shift
            ;;
        --raw)   shift
            OPT_RAW=$1
            shift
            ;;
        -y|--year)   shift
            YEAR=$1
            shift
            ;;
        -2|--h2h)   shift
            # will be prompted for a second player
            OPT_TWO=1
            ;;
        -e|--event)   shift
            EVENT=$1
            shift
            case $EVENT in 
                AO|ao) EVENT="Australian Open"
                    ;;
                FO|fo) EVENT="Roland Garros"
                    ;;
                WO|wo) EVENT="Wimbledon"
                    ;;
                USO|uso) EVENT="US Open"
                    ;;
                SLAM|slam) EVENT="\-5[2468]0"
                    ;;
                WTF|wtf) EVENT="\-605"
                    ;;
            esac

            ;;
        -r|--round)   shift
            ROUND=$1
            shift
            ;;
        --level)   shift
            OPT_LEVEL=$1
            OPT_FILTER=1
            shift
            ;;
        --surface)   shift
            OPT_SURFACE=$1
            OPT_FILTER=1
            shift
            ;;
        -V|--verbose)   shift
            OPT_VERBOSE=1
            ;;
        --debug)        shift
            OPT_DEBUG=1
            ;;
        -h|--help)
            cat <<-! | sed 's|^     ||g'
            $0 Version: 0.0.0 Copyright (C) 2016 jkepler
            This program prints match results from ATP events (non future/challenger)
             for players, year. events, rounds.

            Usage:
            To see matches of a player ( you will be prompted for other fields)
            $0 [playername]
            To see matches of Federer vs Nadal
            $0 Federer Nadal
            To see matches of two players in a given year pass a number starting with 19 or 20
            $0 Federer Djokovic 2012
            To see matches for an event, pass part of event starting with '@'
            $0 federer 2012 @austral

            Options:
            -p  --player      Name of player to filter on
            -2  --h2h         Will be prompted for a second player
            -y  --year        Year filter. Can be 201 or 200 or 198 or 2009
            -e  --event       Event filter. e.g US Open, Roland Garros, Australian Open, Wimbledon
                              As special cases:
                              slam - takes all four majors into account
                              wtf  - take World Tour Final/TMC/YEC 
            -r  --round       Round: F SF QF R16 R32 R64 R128. Or .* for all

            -V  --verbose     Displays more information
            --debug       Displays debug information
!
            # no shifting needed here, we'll quit!
            exit
            ;;
        --edit)
            echo "this is to edit the file generated if any "
            exit
            ;;
        --source)
            echo "this is to edit the source "
            vim $0
            exit
            ;;
        *)
            echo "Error: Unknown option: $1" >&2   
            echo "Use -h or --help for usage" 1>&2
            exit 1
            ;;
    esac
done

_format() {

    text="$*"
    if [[ -z "$OPT_RAW" ]]; then
        echo -e "$text" | csvlook -d, -H $OPT_LINE_NUMBER
    else
        echo "$text" | tr ',' '\t'
    fi
}
_filter() {
    if [[ -n "$OPT_LEVEL" ]]; then
        text=$( echo "$text" | awk -F"," -v level="$OPT_LEVEL" '$5==level {print $0}' )
    fi
    if [[ -n "$OPT_SURFACE" ]]; then
        text=$( echo "$text" | awk -F"," -v level="$OPT_SURFACE" '$3==level {print $0}' )
    fi
}
# arguments
# -1 is part of players name
# after that, if number then it can be year 19.. 20..
# if @xxx then it is event @australian @wimble. $0 federer @austra
# if second string then opponent. $0 federer nadal

if [  $# -gt 0 ]; then
    # part of player name
    ARG1="$1"
    shift
fi
for var in "$@"
do
    echo "$var"
    if [[ $var =~ ^[12][90]* ]]; then
        YEAR=$var
    elif [[ $var =~ ^@ ]]; then
        ARGEVENT=${var#@}
        case $ARGEVENT in
            slam|SLAM)
                EVENT="\-5[2468]0"
                ;;
            WTF|wtf) EVENT="\-605"
                ;;
        esac
    else
        ARGOPPONENT=$var
        OPT_TWO=1
    fi
done
if [[ -z "$YEAR" ]]; then
    echo -n "Enter year? "
    read YEAR
fi

if [[ -z "$PRO" ]]; then
    # the full list gives a huge list many of whom have not won or lost anything in the main tour
    #PRO=$( cut -f2-3 -d, ./atp_players.csv | tr ',' ' ' | fzf --query="$1" -1 -0)
    if [[ -n "$YEAR" ]]; then
        # if we have the year/years we can extract players only for that period
        PRO=$(cut -d, -f11,21 atp_matches_${YEAR}*.csv | tr ',' '\n' | sort -u | fzf --prompt="Player: " --query="$ARG1" -1 -0)
    else
        # this is still over 5000 names
        PRO=$( cat ./players.list | fzf --query="$ARG1" -1 -0)
    fi
    echo "PRO: $PRO"
fi
if [[ -n "$PRO" ]]; then
    # if user has selected a player, and asked for opponent, then get names that player has played against
    if [[ -n "$OPT_TWO" ]]; then
        # filter out matches played by PRO and get other player. 
        # Need to remove PRO from list
        OPPONENT=$(grep "$PRO" atp_matches_${YEAR}*.csv | cut -d, -f11,21 | tr ',' '\n' | sort -u | fzf --prompt="Opponent: " --query="${ARGOPPONENT}" -1 -0)
        echo "Opponent: $OPPONENT "
    fi
fi
if [[ -z "$EVENT" ]]; then
    # NOTE should we filter events played by PRO only
    # Filter events for the surface
    echo "Select an event:"
    XYEAR=${YEAR:-"2015"}
    if [[ -n "$XYEAR" ]]; then
        # 2 3 5 are event name, surface and level
        EVENT=$( cut -f2,3,5 -d, ./atp_matches_${XYEAR}*.csv | fgrep -v Davis )
        if [[ -n "$OPT_SURFACE" ]]; then
            EVENT=$( echo "$EVENT" | grep "${OPT_SURFACE}" )
        fi
        if [[ -n "$OPT_LEVEL" ]]; then
            EVENT=$( echo "$EVENT" | grep "${OPT_LEVEL}$" )
        fi
        
        EVENT=$( echo "$EVENT" | cut -d, -f1 | sort -u | fzf --query="${ARGEVENT}" -1 -0)
        echo $EVENT
    fi
fi
if [[ -z "$ROUND" ]]; then
    echo "Select a round (F SF QF R16 R32 R64 R128): (blank for all)"
    read ROUND
fi
if [[ -n "$ROUND" ]]; then
    #ROUND=",${ROUND},"
    ROUND=",${ROUND}"
    #echo $ROUND
fi
if [[ -n "$OPT_VERBOSE" ]]; then
    echo "EVENT : $EVENT."
    echo "PRO : $PRO."
    echo "ROUND : $ROUND."
    echo "YEAR : $YEAR."
fi
# NOTE WTF contains another field with ,F, in each row, so round does not work in the first grep
# NOTE egrep is required so we can club two rounds like (SF|F)
# We need to put into a table and sql it out.
#echo "Round=$ROUND"

#egrep -ih "${EVENT}.*${PRO}" ./atp_matches_${YEAR}*.csv | cut -d, -f6,2,11,21,28,30 | grep "${OPPONENT}.*${ROUND}$" | csvlook -H
text=$(egrep -ih "${EVENT}.*${PRO}" ./atp_matches_${YEAR}*.csv )
# TODO OPT_SURFACE and OPT_LEVEL accept as options
if [[ -n "$OPT_FILTER" ]]; then
    _filter "$text"
fi
text=$(echo "$text" |  cut -d, -f6,2,11,21,28,30 | grep "${OPPONENT}.*${ROUND}$" )
_format "$text"
