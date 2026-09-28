#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# comment 1
# توليد رقم عشوائي بين 1 و 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
# comment 2
# طلب اسم المستخدم
echo "Enter your username:"
read USERNAME
# comment 3
# جلب ID المستخدم
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# إذا كان المستخدم جديداً
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # إذا كان مستخدماً سابقاً
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# بدء التخمين
echo "Guess the secret number between 1 and 1000:"
read GUESS

TRIES=1

while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  # التحقق مما إذا كان المدخل ليس رقماً صحيساً
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    ((TRIES++))
  else
    echo "It's higher than that, guess again:"
    ((TRIES++))
  fi
  read GUESS
done

# رسالة الفوز
echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"

# حفظ نتيجة اللعبة في قاعدة البيانات
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $TRIES)")
