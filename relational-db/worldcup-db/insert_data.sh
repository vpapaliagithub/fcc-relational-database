#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# **************************************************************

# empty tables
echo $($PSQL "truncate teams, games;")

# fill the tables
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS 
# cat games_test.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS 
do 
  if [[ $WINNER != winner && $OPPONENT != opponent ]]
  then
    ### 1. fill the teams table

    # get team_id for winners
    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER';")
    if [[ -z $WINNER_ID ]]
    then
      # insert team
      INSERT_WINNER_RESULT=$($PSQL "insert into teams(name) values('$WINNER');")
      if [[ $INSERT_WINNER_RESULT=='INSERT 0 1' ]]
      then 
        echo "$WINNER team was inserted."
      fi
      # get the winner_id
      WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER';")
    fi
    ## do the same for opponents
    # get team_id for opponents
    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT';")
    if [[ -z $OPPONENT_ID ]]
    then
      # insert team
      INSERT_OPPONENT_RESULT=$($PSQL "insert into teams(name) values('$OPPONENT');")
      if [[ $INSERT_OPPONENT_RESULT=='INSERT 0 1' ]]
      then 
        echo "$OPPONENT team was inserted."
      fi
      # get the opponent_id
      OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT';")
    fi

    ### 2. fill the games table
    # all rows from games.csv will be inserted into the table
    INSERT_GAME_RESULT=$($PSQL "insert into games 
      (year, round, winner_id, opponent_id, winner_goals, opponent_goals)
      values ('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS');")
    # insert into games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) values ();
    if [[ $INSERT_GAME_RESULT=='INSERT 0 1' ]]
    then 
      echo "game was inserted."
    fi
  fi # exclude 1st line (titles) 
done