#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
#check if we have an input

if [ $# -eq 0 ];
then
  echo "Please provide an element as an argument."
  exit 0
fi

#Extract the first argument
INPUT=$1

#Check if input is:
#Equal to atomic_number (from elements table)
if [[ $INPUT =~ ^[0-9]+$ ]];
then
  INFO=$($PSQL "SELECT elements.atomic_number, symbol, name, type, 
  atomic_mass, melting_point_celsius, boiling_point_celsius 
  FROM properties 
  JOIN elements ON properties.atomic_number = elements.atomic_number
  JOIN types ON properties.type_id = types.type_id
  WHERE elements.atomic_number = '$INPUT';")

#Equal to symbol (from elements table) (capitals or none are accepted)
#Equal to name (from elements table)
else
  INFO=$($PSQL "SELECT elements.atomic_number, symbol, name, type, 
  atomic_mass, melting_point_celsius, boiling_point_celsius  
  FROM properties 
  JOIN elements ON properties.atomic_number = elements.atomic_number
  JOIN types ON properties.type_id = types.type_id
  WHERE UPPER(symbol) = UPPER('$INPUT') OR name = '$INPUT';")

fi

#If element INFO is not empty:
if [ -n "$INFO" ]; 
then
  # Parse element information
  read -r atomic_number symbol name type atomic_mass melting_point_celsius boiling_point_celsius <<< "$(echo "$INFO" | tr '|' ' ')"
  
  echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."

#if element INFO is empty:
else
  echo "I could not find that element in the database."
fi
