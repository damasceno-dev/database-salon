#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

MAIN_MENU() {
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")

  if [[ $1 ]]
  then
    echo -e "\n\n\n$1"
  fi 

  echo -e "\nHere are the services we have available:"
  echo "$AVAILABLE_SERVICES" | while read ID BAR NAME
  do
    echo "$ID) $NAME"
  done
  echo "0) exit program"
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED = 0 ]]
  then
    echo -e "\nThank you for stopping in.\n"
    exit
  fi  

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That is not a valid number."
    else 
    VALID_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $VALID_SERVICE ]]
    then 
      MAIN_MENU "That is not a valid option."
    else
      SCHEDULE_MENU $VALID_SERVICE
    fi
  fi
}

SCHEDULE_MENU() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $1")
  echo -e "\nYOU HAVE PICKED:$SERVICE_NAME\n"

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  echo -e "\nWhat's the time for your appointment?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$1', '$SERVICE_TIME')")

  echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
}

MAIN_MENU