#!/usr/bin/env bash

#
# Argument parsing
#
# defaults
DB_FILE=/tmp/logs.db
REGEX="r'^\[(?P<level>\w+)\] (?P<datetime>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}) \[(?P<thread>\S+)\] (?P<class>\S+) (?P<method>\S+) - (?P<log>(.+(\n(?!\[).+|)+))'"

usage="$(basename "$0") [-h] [-i INFILE] [-c COMPONENT] [-t TABLE] [-f FORMAT] [-d DATABASE]
Imports a log file into sqlite for further analysis
where:
    -h  show this help text
    -i  input log file
    -c  component name to be added as a column
    -t  target table name
    -f  log format (possible values: CFK, none/DEFAULT)
    -d  Target database file (default: $DB_FILE)
    "

options=':h:i:c:t:f:d:'
while getopts $options option; do
  case "$option" in
    h) echo "$usage"; exit;;
    i) INFILE=$OPTARG;;
    c) COMPONENT=$OPTARG;;
    t) TABLE=$OPTARG;;
    f) FORMAT=$OPTARG;;
    d) DB_FILE=$OPTARG;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
  esac
done

# mandatory arguments
if [ ! "$INFILE" ] || [ ! "$COMPONENT" ] || [ ! "$TABLE" ]; then
  echo "arguments -i, -c and -t must be provided"
  echo "$usage" >&2; exit 1
fi

case "$FORMAT" in
    CFK)
        REGEX="r'^\[(?P<level>\w+)\] (?P<datetime>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}) \[(?P<thread>\S+)\] (?P<class>\S+) (?P<method>\S+) - (?P<log>(.+(\n(?!\[).+|)+))'"
    ;;
    *)
        REGEX="r'^\[(?P<datetime>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3})\] (?P<level>\w+) (?P<log>(.+(\n(?\!\[).+|)+))'"
    ;;
esac
  
#
# Parse and import logs
#
sqlite-utils insert $DB_FILE $TABLE $INFILE --text --convert "
import re
r = re.compile($REGEX, re.MULTILINE)

def convert(text):
    rows = [m.groupdict() for m in r.finditer(text)]

    for row in rows:
        row.update({'component': '$COMPONENT'})

    return rows
"
