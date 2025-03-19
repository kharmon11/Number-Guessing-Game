#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

guessing_game() {
  SECRET_NUMBER=$1
  TOTAL_GUESSES=$2
  USERNAME=$3
  GAMES_PLAYED=$4
  BEST_GAME=$5

  read GUESS
  ((TOTAL_GUESSES++))
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      if [[ $TOTAL_GUESSES -lt $BEST_GAME ]]
      then
        BEST_GAME=$TOTAL_GUESSES
      fi
      if [[ $GAMES_PLAYED -eq 0 ]]
      then
        $PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $BEST_GAME)" > /dev/null
      else
        $PSQL "UPDATE users SET games_played = games_played + 1, best_game = $BEST_GAME WHERE username = '$USERNAME'" > /dev/null
      fi
      echo "You guessed it in $TOTAL_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      guessing_game $SECRET_NUMBER $TOTAL_GUESSES $USERNAME $GAMES_PLAYED $BEST_GAME
    else
      echo "It's higher than that, guess again:"
      guessing_game $SECRET_NUMBER $TOTAL_GUESSES $USERNAME $GAMES_PLAYED $BEST_GAME
    fi
  else
    echo "That is not an integer, guess again:"
    guessing_game $SECRET_NUMBER $TOTAL_GUESSES $USERNAME $GAMES_PLAYED $BEST_GAME
  fi
}

echo "Enter your username:"
read USERNAME_INPUT  
USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME_INPUT'")
if [[ -z $USER ]]
then
  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  USERNAME=$USERNAME_INPUT
  GAMES_PLAYED=0
  BEST_GAME=9999
else
  IFS='|' read -r USERNAME GAMES_PLAYED BEST_GAME <<< $USER
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % (1000 -1 + 1) + 1 ))
echo "Guess the secret number between 1 and 1000:"
guessing_game $SECRET_NUMBER 0 $USERNAME $GAMES_PLAYED $BEST_GAME
