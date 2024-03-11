#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read -r USER

#  check if user already in the database
PLAYER=$($PSQL "SELECT username FROM users WHERE username = '$USER'")

# if new player 
if [[ -z $PLAYER ]]
then # insert into database
  INSERT_PLAYER=$($PSQL "INSERT INTO users(username) VALUES('$USER')")
  # update games table and insert new username
  UPDATE_GAMES_PLAYER=$($PSQL "UPDATE games SET username = '$USER' WHERE guess_number IS NULL")
  # print user welcome message
  echo "Welcome, $USER! It looks like this is your first time here."
else 
  # get existing user stats
  PLAYER=$($PSQL "SELECT games.username, COUNT(*), MIN(guess_number) FROM games FULL JOIN users USING(username) WHERE games.username = '$USER' GROUP BY games.username")
  # print existing user and stats
  echo "$PLAYER" | while IFS="|" read -r username g_played b_game 
  do 
    echo "Welcome back, $username! You have played $g_played games, and your best game took $b_game guesses."
  done
fi


# generate random number
SECRET_N=$((RANDOM % 1000 + 1))

# ask for guess 
echo "Guess the secret number between 1 and 1000:"
while true; read -r GUESS; 
do # initialize counter
  ((guess_number++))
  if [[ ! $GUESS =~ ^[0-9]+$  ]]
  then 
    echo "That is not an integer, guess again:"
  else # check if guess < than random number 
    if [[ $GUESS -lt $SECRET_N ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $GUESS -gt $SECRET_N ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "You guessed it in $guess_number tries. The secret number was $SECRET_N. Nice job!"
      # insert game into database
      INSERT_INTO_GAMES=$($PSQL "INSERT INTO games(username, guess_number) VALUES('$USER',$guess_number)")
      #exit the loop
      break
    fi
  fi
done

