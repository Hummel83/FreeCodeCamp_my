#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if argument exists
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Query the database
QUERY_RESULT=$($PSQL "
  SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, 
         p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  INNER JOIN properties p ON e.atomic_number = p.atomic_number
  INNER JOIN types t ON p.type_id = t.type_id
  WHERE e.atomic_number::TEXT = '$1' OR e.symbol = '$1' OR e.name = '$1';
")

if [[ -z $QUERY_RESULT ]]
then
  echo "I could not find that element in the database."
else
  # Format and output
  IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$QUERY_RESULT"
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
fi
