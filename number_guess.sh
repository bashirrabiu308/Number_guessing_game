#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


echo "Enter your username:"
read USERNAME
while [[ -z $USERNAME ]]
do
  echo "Please enter a username:"
  read USERNAME
done

USER_INFO=$($PSQL "SELECT games_played || ' ' || best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  GAMES_PLAYED=0
  BEST_GAME=0
else
  read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0

while true
do
  read GUESS

  if ! [[ $GUESS =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    ((NUMBER_OF_GUESSES++))

    if [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      break
    fi
  fi
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

GAMES_PLAYED=$((GAMES_PLAYED + 1))

if [[ $BEST_GAME -eq 0 ]] || [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  BEST_GAME=$NUMBER_OF_GUESSES
fi

UPDATE_USER=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")


