#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# randomly generate a number between 1 and 1000 that users have to guess
NUMBER_TO_BE_GUESSED=$((1 + $RANDOM % 1000))
# counter to keep track of the number of guesses made by the user
NUMBER_OF_GUESSES_THIS_GAME=1

MAIN_MENU() {
# prompt the user for their username
echo "Enter your username:"
read USERNAME_INPUT
# search the database to see if that name already exists
RESULT_USERNAME_SEARCH=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME_INPUT'")
# if the username is not found in the db a welcome message is printed
if [[ -z $RESULT_USERNAME_SEARCH ]]
then
  RESULT_INSERT_NEW_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME_INPUT', 0, 10000)")
  echo -e "\nWelcome, $USERNAME_INPUT! It looks like this is your first time here."
else
  # If the username has been used before, print a summary welcome back message.
  RESULT_GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME_INPUT'")
  RESULT_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME_INPUT'")
  echo -e "Welcome back, $USERNAME_INPUT! You have played $RESULT_GAMES_PLAYED games, and your best game took $RESULT_BEST_GAME guesses."
fi

# ask the user to guess the number that was randomly generated at the top of this script
echo -e "\nGuess the secret number between 1 and 1000:"
HANDLE_GUESS
}

HANDLE_GUESS() {
  # take in a user's guess
  read USER_GUESS
  # test whether the guess is a number or not
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]] 
  then
    echo "That is not an integer, guess again:"
    HANDLE_GUESS
  # test whether the user's guess is greater than the target number
  elif [[ $USER_GUESS -gt $NUMBER_TO_BE_GUESSED ]]
  then
    echo "It's lower than that, guess again:"
    ((NUMBER_OF_GUESSES_THIS_GAME++))
    HANDLE_GUESS
  # test whether the user's guess is less than the target number
  elif [[ $USER_GUESS -lt $NUMBER_TO_BE_GUESSED ]]
  then
    echo "It's higher than that, guess again:"
    ((NUMBER_OF_GUESSES_THIS_GAME++))
    HANDLE_GUESS
  # if the guess is correct, update the db and print the congratulation message
  else
    UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME_INPUT'")
    UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES_THIS_GAME WHERE username = '$USERNAME_INPUT' AND best_game > $NUMBER_OF_GUESSES_THIS_GAME")
    echo -e "\nYou guessed it in $NUMBER_OF_GUESSES_THIS_GAME tries. The secret number was $NUMBER_TO_BE_GUESSED. Nice job!"
  fi
}

# this is called at the end to make sure that all functions are in scope
MAIN_MENU
