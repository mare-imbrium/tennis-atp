#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: h2h.sh
# 
#         USAGE: ./h2h.sh player1 player2
# 
#   DESCRIPTION: show bothways whenever p1 has met p2
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 02/05/2016 23:43
#      REVISION:  2016-02-07 16:12
#===============================================================================

OPT_VERBOSE=
OPT_DEBUG=
OPT_COLS="1,2,11,21,28,30"
while [[ $1 = -* ]]; do
    case "$1" in
        -V|--verbose)   shift
            OPT_VERBOSE=1
            ;;
        --raw)   shift
            OPT_RAW=1
            ;;
        --slam)   shift
            OPT_SLAM=1
            OPT_EVCODE="\-5[2468]0.*"
            ;;
        --masters)   shift
            OPT_LEVEL=M
            OPT_FILTER=1
            #OPT_EVCODE="\-5[2468]0.*"
            ;;
        -n|--numbering)   shift
            OPT_LINE_NUMBER="-l"
            ;;
        --total)   shift
            OPT_TOTAL=1
            ;;
        --surface)   shift
            OPT_SURFACE=$1
            OPT_FILTER=1
            shift
            ;;
        --level)   shift
            OPT_LEVEL=$1
            OPT_FILTER=1
            shift
            ;;
        --show-surface)   shift
            OPT_COLS="${OPT_COLS},3"
            ;;
        --show-level)   shift
            OPT_COLS="${OPT_COLS},5"
            # M - masters, G - slam, A - smaller ones
            ;;
        --debug)        shift
            OPT_DEBUG=1
            ;;
        -h|--help)
            cat <<-! | sed 's|^     ||g'
            $0 Version: 0.0.0 Copyright (C) 2016 jkepler
            This program prints matches played by two given players.
            Data is taken from the csv files on disk.

            The output is filtered through csvlook

            Usage:
            $0 Federer Nadal
            $0 -raw Federer Berdych

            Options:
                --raw       Output is not formatted, and is tab delimited. No numbering.
                --total     Display total matches, and wins for each player
            -n  --numbering Display line numbering
                --slam      Display only majors
                --surface   <surface>   Filter on given surface (Hard, Clay, Grass)
                --level     M G A  Show only Masters or Grand Slams or A (Others)
                --show-surface   Display surface
                --show-level   Display level (M - Masters, G - Majors, A - others_
            -V  --verbose   Displays wins for each player after the common table
                --debug     Displays debug information
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
if [  $# -lt 2 ]; then
    echo -e "Please pass names of two player using Initcaps" 1<&2
    exit -1
fi

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

#grep -h "$1" atp_matches_*.csv | grep "$2" | cut -d, -f1,2,11,21,28,30 | csvlook -d, -H -l
#text=$( grep -h "$1" atp_matches_*.csv | grep "$2" | cut -d, -f1,2,11,21,28,30 )
#text=$( grep -h "${OPT_EVCODE}$1" atp_matches_*.csv | grep "$2" | cut -d, -f${OPT_COLS} )
text=$( grep -h "${OPT_EVCODE}$1" atp_matches_*.csv | grep "$2" )
if [[ -n "$OPT_FILTER" ]]; then
    _filter "$text"
fi
text=$( echo "$text" | cut -d, -f${OPT_COLS} )
_format "$text"
if [[ -n "$OPT_TOTAL" ]]; then
    echo -n "Total: "
    echo "$text" | grep -c .
    echo -n "$1: "
    echo "$text" | grep -c "$1.*$2"
    echo -n "$2: "
    echo "$text" | grep -c "$2.*$1"
fi


if [[ -n "$OPT_VERBOSE" ]]; then
    # This is for when you want to see when p1 has beaten p2
    #grep -h "$1.*$2" atp_matches_*.csv | cut -d, -f1,2,11,21,28,30 | csvlook -d, -H -l
    #echo "--------------"
    #grep -h "$2.*$1" atp_matches_*.csv | cut -d, -f1,2,11,21,28,30 | csvlook -d, -H -l
    text=$( grep -h "${OPT_EVCODE}$1.*$2" atp_matches_*.csv | cut -d, -f${OPT_COLS} )
    _format "$text"
    echo "--------------"
    text=$( grep -h "${OPT_EVCODE}$2.*$1" atp_matches_*.csv | cut -d, -f${OPT_COLS} )
    _format "$text"
fi
