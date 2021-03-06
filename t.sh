#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: t.sh
# 
#         USAGE: ./t.sh 
# 
#   DESCRIPTION: view tennis matches info. Matches of a player, matches of an event or year or surface.
#   Matches between two players, matches won/lost by a player.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: senti
#  ORGANIZATION: 
#       CREATED: 02/05/2016 20:59
#      REVISION:  2018-02-16 14:44
#
# = Changelog
# - 2018-02-16 - v1.2
#              - don't print if no matches between two given players
# - 2016-02-13 - v1.1 
#              - added --extra so we can throw in more columns in the output
# - 2016-02-12 - v1.1
#              - added multiple values for year, level, round, surface
# - 2016-02-11 - added --fullname option to get fullname
#              - added --seed option to display seed of player
#===============================================================================


DB=tennis.db
#cd ~/Downloads/tennis_atp-master
cd /Volumes/Pacino/dziga_backup/rahul/Downloads/tennis_atp-master

OPT_SQL=""

_debug() {
    local str="$*"
    if [[ -n "$OPT_DEBUG" ]]; then
        echo -e "$str"
    fi
}
_quote_comma() {
    # a string such as "SF,F" will be returned as ('SF','F')
    RESULT=$(echo "$*" | tr ',' '\n' | sed "s/.*/'&'/" | tr '\n' ',' | sed 's/^/(/;s/,$/)/' )
}
_format() {

    text="$*"
    if [[ -z "$text" ]]; then
        return 1
    fi
    if [[ -z "$OPT_RAW" ]]; then
        # formatted text, pass through csvlook and print totals`yy
        echo -e "$text" | csvlook --tabs  $OPT_LINE_NUMBER
        # print number of rows
        echo -n "Results: "
        ct=$( echo -e "$text" | wc -l )
        # decrease one due to header row
        (( ct-- ))
        echo "$ct"
    else
        # unformatted text, just print
        echo "$text" 
    fi
}
# ----- filter_names ------------------------------------ #
# filters names based on criteria given such as level, surface etc
# if two names are given then filters second based on first -- only those who have played
#   with the first name.
_filter_names() {
    _debug "OPT_SQL ${OPT_SQL}"
    local xxx="1=1"
    [[ -n "$PRO" ]] && { xxx="(winner_name = '"${PRO}"' OR loser_name = '"${PRO}"' )"; }
    _debug "xxx ${xxx}"
    names=$( sqlite3 $DB <<!
   select winner_name, loser_name from matches where ${xxx} ${OPT_SQL};
!
       )
       names=$( echo "$names" | tr '|' '\n' | sort -u )
}

_filter_winners() {
    _debug "OPT_SQL ${OPT_SQL}"
    # pass in winner or loser
    local worl="$1"
    local xxx="1=1"
    [[ -n "$PRO" ]] && { xxx="(winner_name = '"${PRO}"' OR loser_name = '"${PRO}"' )"; }
    names=$( sqlite3 $DB <<!
   SELECT ${worl}_name FROM matches WHERE ${xxx} ${OPT_SQL};
!
    )
    names=$( echo "$names" | sort -u )
}

OPT_VERBOSE=
OPT_DEBUG=
# put this in variable since we need to give full names if requested
SQL_NAME_W="p.lastName "
SQL_NAME_L="p1.lastName "

# -------------- process command line options --------------------- #
shopt -s extglob
while [[ $1 = -* ]]; do
    case "$1" in
        -r|--round)   shift
            ROUND=$1
            if [[ $ROUND = *,* ]]; then
                _quote_comma $ROUND
                ROUND="${RESULT}"
                OPT_SQL="${OPT_SQL} AND round  IN ${ROUND}"
            else
                OPT_SQL="${OPT_SQL} AND round  = '"${ROUND}"'"
            fi
            shift
            ;;
        --raw|--tabs)   shift
            OPT_RAW=$1
            ;;
        -n|--numbering)   shift
            OPT_LINE_NUMBER="-l"
            ;;
        -y|--year)   shift
            YEAR=$1
            shift
            ;;
        -w|--winner)   shift
            OPT_WINNER=$1
            shift
            ;;
        -l|--loser)   shift
            OPT_LOSER=$1
            shift
            ;;
        --fullname)   shift
            OPT_FULLNAME=1
            ;;
        --seed)   shift
            OPT_SEED=1
            ;;
        -e|--event)   shift
            EVENT=$1
            shift
            case $EVENT in 
                AO|ao) EVENT="Australian Open"
                    OPT_SQL="${OPT_SQL} AND tourney_level = '"${EVENT}"'"
                    ;;
                FO|fo) EVENT="Roland Garros"
                    OPT_SQL="${OPT_SQL} AND tourney_level = '"${EVENT}"'"
                    ;;
                WO|wo) EVENT="Wimbledon"
                    OPT_SQL="${OPT_SQL} AND tourney_level = '"${EVENT}"'"
                    ;;
                USO|uso) EVENT="US Open"
                    OPT_SQL="${OPT_SQL} AND tourney_level = '"${EVENT}"'"
                    ;;
                SLAM|slam) EVENT="\-5[2468]0"
                    OPT_SQL="${OPT_SQL} AND tourney_level = 'G'"
                    ;;
                master|masters) 
                    OPT_SQL="${OPT_SQL} AND tourney_level = 'M'"
                    ;;
                WTF|wtf) EVENT="\-605"
                    OPT_SQL="${OPT_SQL} AND tourney_id LIKE '%-605'"
                    ;;
                *)
                    OPT_SQL="${OPT_SQL} AND tourney_name  = '"${EVENT}"'"
                    ;;
            esac

            ;;
        --level)   shift
            OPT_LEVEL=$1
            if [[ $OPT_LEVEL = *,* ]]; then
                _quote_comma $OPT_LEVEL
                OPT_LEVEL="${RESULT}"
                OPT_SQL="${OPT_SQL} AND tourney_level  IN ${OPT_LEVEL}"
            else
                OPT_SQL="${OPT_SQL} AND tourney_level  = '"${OPT_LEVEL}"'"
            fi
            shift
            ;;
        --surface)   shift
            OPT_SURFACE=$1
            if [[ $OPT_SURFACE = *,* ]]; then
                _quote_comma $OPT_SURFACE
                OPT_SURFACE="${RESULT}"
                OPT_SQL="${OPT_SQL} AND surface IN ${OPT_SURFACE}"
            else
                OPT_SQL="${OPT_SQL} AND surface  = '"${OPT_SURFACE}"'"
            fi
            shift
            ;;
        -V|--verbose)   shift
            OPT_VERBOSE=1
            ;;
        --debug)        shift
            OPT_DEBUG=1
            ;;
        -x|--extra)   shift
            # add extra columns names to display starting with a comma.
            # e.g., ", tourney_level, surface"
            EXTRA_COLS=$1
            shift
            ;;
        -h|--help)
            APPNAME=$(basename $0)
            cat <<-! | sed 's|^     ||g'
            $APPNAME Version: 1.1.0 Copyright (C) 2016 jkepler
            This program prints match results from ATP events (non future/challenger)
             for players, year. events, rounds. 
                 (Data thanks to Jeff Sackman: https://github.com/JeffSackmann/tennis_atp)

            Usage:
            To see matches of a player 
                $APPNAME [playername]
            To see matches of Federer vs Nadal
                $APPNAME Federer Nadal
            To see matches of two players in a given year pass a number starting with 19 or 20
                $APPNAME Federer Djokovic 2012
            To see matches for an event, pass part of event starting with '@'
                $APPNAME federer 2012 @austral
            To see Nadals matches against Djokovic on clay in 2012. Other values are grass and hard.
                $APPNAME nadal 2012 clay Djokovic
            To see matches where a player was the winner:
                $APPNAME --winner Nadal 2013
                $APPNAME --winner Nadal --loser Djokovic 2013

            Options:
            -y  --year        Year filter. Can be 201 or 200 or 198 or 2009
            -e  --event       Event filter. e.g US Open, Roland Garros, Australian Open, Wimbledon
                              As special cases:
                              slam - takes all four majors into account
                              wtf  - take World Tour Final/TMC/YEC 
            -r  --round TYPE  Round: F SF QF R16 R32 R64 R128. Or .* for all
                --level TYPE  Filter by level. G=slams, M=masters, A=lower
                --surface TYPE Types are Clay , Hard , Grass. Filter by surface
                --winner NAME Display matches won by given player
                --loser  NAME Display matches lost by given player

            -V  --verbose     Displays more information
            --debug           Displays debug information
            -n|--numbering    csvlook will number first column
            --raw             Display information with TAB separator, no tables

            The following allow multiple values, separated by commas.:
            --round SF,F
            --level G,M
            --surface Grass,Clay
            --year 2000,2001   In this case, full year must be given
!

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
#if [  $# -gt 0 ]; then
    ## part of player name
    #ARG1="$1"
    #shift
#fi
for var in "$@"
do
    _debug "$var"
    if [[ $var =~ ^[12][90]* ]]; then
        YEAR=$var
    elif [[ $var =~ ^@ ]]; then
        ARGEVENT=${var#@}
        case $ARGEVENT in
            slam|SLAM|major)
                EVENT="\-5[2468]0"
                OPT_LEVEL=G
                OPT_SQL="${OPT_SQL} AND tourney_level = 'G'"
                ;;
            WTF|wtf) EVENT="\-605"
                OPT_LEVEL=M
                OPT_SQL="${OPT_SQL} AND tourney_id LIKE '%-605'"
                ;;
            master|masters) 
                OPT_LEVEL=M
                OPT_SQL="${OPT_SQL} AND tourney_level = 'M'"
                ;;
            *)
                # NOTE: should  we should fzf it ? But sometimes the word Masters is not there.
                OPT_SQL="${OPT_SQL} AND tourney_name LIKE '"${ARGEVENT}%"'"
                ;;
        esac
    else
        case $var in 
            [Cc]lay|[Gg]rass|[Hh]ard)
                svar="${var^}"
                OPT_SQL="${OPT_SQL} AND surface = '"${svar}"'"
                ;;
            *)
                if [[ -z "$ARG1" ]]; then
                    ARG1="$var"
                elif [[ -z "$ARGOPPONENT" ]]; then
                    ARGOPPONENT=$var
                fi
        esac

    fi
done
if [[ -n "$YEAR" ]]; then
    if [[ $YEAR = *,* ]]; then
        # NOTE if years are given they must be full years since LIKE is not used
        _quote_comma $YEAR
        YEAR="${RESULT}"
        OPT_SQL="${OPT_SQL} AND substr(tourney_date,1,4) IN ${YEAR}"
    else
        OPT_SQL="${OPT_SQL} AND tourney_date LIKE '"${YEAR}"%'"
    fi
fi
# ------------- determine exact name of pro ---------------------- #

if [[ -n "$OPT_WINNER" ]]; then
    _filter_winners "winner"
    PRO=$( echo "$names" | fzf --prompt="Winner: " --query="$OPT_WINNER" -1 -0)
    if [[ -n "$OPT_LOSER" ]]; then
        _filter_winners "loser"
        OPPONENT=$( echo "$names" | fzf --prompt="Loser: " --query="$OPT_LOSER" -1 -0)
    fi
elif [[ -n "$OPT_LOSER" ]]; then
    _filter_winners "loser"
    PRO=$( echo "$names" | fzf --prompt="Loser: " --query="$OPT_LOSER" -1 -0)
fi

if [[ -n "$ARG1" ]]; then
    if [[ -z "$PRO" ]]; then
        _filter_names
        PRO=$( echo "$names" | fzf --prompt="Player: " --query="$ARG1" -1 -0)
    fi
fi
if [[ -n "$ARGOPPONENT" ]]; then
    if [[ -z "$OPPONENT" ]]; then
        _filter_names
        _debug "names is $names"
        OPPONENT=$( echo "$names" | fzf --prompt="Opponent: " --query="$ARGOPPONENT" -1 -0)
        _debug "OPPONENT is $OPPONENT"
        # 2018-02-16 - don't print if no matches with second player
        if [[ -z "$OPPONENT" ]]; then
            echo "Seems there were no matches between $PRO and $ARGOPPONENT"
            exit -1
        fi
    fi
fi
# ----- no pro selected, we want match result, we don't know who won or lost
if [[ -z "$PRO" ]]; then
    OPT_PRO="1 = 1"
else
    if [[ -n "$OPT_WINNER" && -n "$OPT_LOSER" ]]; then
        OPT_PRO="( winner_name = '"${PRO}"' AND loser_name = '"${OPPONENT}"'  )"
    elif [[ -n "$OPT_WINNER" ]]; then
        OPT_PRO="( winner_name = '"${PRO}"'  )"
    elif [[ -n "$OPT_LOSER" ]]; then
        OPT_PRO="( loser_name = '"${PRO}"'  )"
    elif [[ -n "$OPPONENT" ]]; then
        OPT_PRO="( (winner_name = '"${PRO}"' AND loser_name = '"${OPPONENT}"' ) OR (winner_name = '"${OPPONENT}"' and loser_name = '"${PRO}"') )"
    else
        OPT_PRO="( winner_name = '"${PRO}"' or loser_name = '"${PRO}"' )"
    fi
fi
#select tourney_date as tdate, tourney_name, winner_name, cast(winner_age as int) as age, loser_name, cast(loser_age as int) as age, score, round from matches where $OPT_PRO  $OPT_SQL ;
_debug "OPT_PRO $OPT_PRO"
if [[ -n "$OPT_FULLNAME" ]]; then
    SQL_NAME_W="p.firstName || ' ' || p.lastName "
    SQL_NAME_L="p1.firstName || ' ' || p1.lastName "
fi
if [[ -n "$OPT_SEED" ]]; then
    SQL_NAME_W="${SQL_NAME_W} || ( CASE WHEN m.winner_seed != '' THEN ' [' || m.winner_seed || ']' ELSE ' ' END) "
    SQL_NAME_L="${SQL_NAME_L} || ( CASE WHEN m.loser_seed != '' THEN ' [' || m.loser_seed || ']' ELSE ' ' END) "
fi
text=$( sqlite3 tennis.db <<!
.header on 
.mode tabs
select tourney_date as tdate, tourney_name as event, ${SQL_NAME_W} as winner, cast(winner_age as int) as age, ${SQL_NAME_L} as loser, cast(loser_age as int) as age, score, round $EXTRA_COLS from matches m, player p, player p1  where m.winner_id = p.id and m.loser_id = p1.id and $OPT_PRO  $OPT_SQL order by tourney_date, match_num;
!
)
_format "$text"
