#!/usr/bin/env ruby -w
# ----------------------------------------------------------------------------- #
#         File: highest.rb
#  Description: 
#       Author: j kepler  http://github.com/mare-imbrium/canis/
#         Date: 2016-02-12 - 18:48
#      License: MIT
#  Last update: 2016-02-13 11:15
# ----------------------------------------------------------------------------- #
# highest.rb  Copyright (C) 2012-2016 j kepler

def filter_names name, where_cond
  mydb = "tennis.db"
  #mytable = "matches"
  xxx = "1=1"
  if name
    # this implies you want a player who has played another which is not applicable here.
    xxx = %[ winner_name = "#{name}" or loser_name = "#{name}" ]
  end
  result = %x{ 
sqlite3 #{mydb} <<!
.mode tabs
   select winner_name, loser_name from matches where #{xxx} #{where_cond};
!
  }
  arr = result.split(/[\n\t]/).uniq
  # split each row and append onto arr, finally uniq it
=begin
  arr = []
  rows.each do |wl|
    a = wl.split("\t")
    arr.concat a
  end
  arr = arr.uniq
=end
  puts "ARR: #{arr.size}" if $opt_verbose
  return arr
end
def resolve_name names, arg_name
  namestr = names.join("\n")
  name = %x[ echo "#{namestr}" | fzf -e --prompt="Player:" --query="#{arg_name}" -1 -0 ]
  #PRO=$( echo "$names" | fzf --prompt="Player: " --query="$ARG1" -1 -0)
  name = name.chomp
  puts "NAME: #{name}" if $opt_verbose
  return name
end
def make_where args
  where_cond = ""
  arg_event = arg_year = arg_surface = arg_round = nil
  arg_name = nil

  args.each do |e|
    if e[0] == "@"
      arg_event = e[1..-1]
    elsif e =~ /^[12][90]/
      arg_year = e
    elsif %w[clay hard grass].include? e.downcase
      arg_surface = e[0].upcase + e[1..-1].downcase
    elsif %w[F SF QF R16 R32 R64 R128].include? e
      arg_round = e
    else
      arg_name = e
    end
  end
  if arg_event
    # TAKE care of @slam and @major
    where_cond = %[ #{where_cond} and tourney_name like "#{arg_event}%" ]
  end
  if arg_year
    # TAKE care of multiple years like 1996,1997 
    where_cond = %[ #{where_cond} and tourney_id like "#{arg_year}%" ]
  end
  if arg_surface
    where_cond = %[ #{where_cond} and surface = "{arg_surface}" ]
  end
  if arg_round
    where_cond = %[ #{where_cond} and round = "{arg_round}" ]
  end
  if arg_name
    names = filter_names nil, where_cond
    name = resolve_name names, arg_name
  else
    raise "Name not given", ArgumentError
  end
  if name
    where_cond = %[ #{where_cond} and ( winner_name = "#{name}" or loser_name = "#{name}") ]
  end
  puts "WHERE_COND: #{where_cond}" if $opt_verbose
  return where_cond
end
def run_sql where_cond
  mydb = "tennis.db"
  #mytable = "matches"
sql=%[select tourney_name, winner_name, loser_name, round from matches where #{where_cond} group by tourney_id order by tourney_id, match_num;]
puts sql if $opt_verbose
result = %x{ 
sqlite3 #{mydb} <<!
.header on
.mode tabs
select tourney_date as tdate, tourney_name, winner_name, loser_name, round from matches where 1=1 #{where_cond} group by tourney_date order by tourney_date, match_num;
!
}
# result is a string with newlines not an array
puts result
end




$opt_verbose = false
if __FILE__ == $0
  begin
    # http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html
    require 'optparse'
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = v
        $opt_verbose = v
      end
    end.parse!

    #p options
    #p ARGV

    #name=ARGV[0] || "Roger Federer";
    where_cond = make_where ARGV
    run_sql where_cond
  ensure
  end
end

