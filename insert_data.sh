#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Leer el archivo CSV y procesar los datos
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Saltar la cabecera del archivo CSV
  if [[ $YEAR != "year" ]]
  then
    # Insertar los equipos en la tabla teams
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') ON CONFLICT (name) DO NOTHING;")
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ON CONFLICT (name) DO NOTHING;")

    # Insertar los datos en la tabla games
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
                                 VALUES($YEAR, '$ROUND', (SELECT team_id FROM teams WHERE name='$WINNER'),
                                        (SELECT team_id FROM teams WHERE name='$OPPONENT'), $WINNER_GOALS, $OPPONENT_GOALS);")
  fi
done
