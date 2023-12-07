#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU() {
  if [[ $1 ]] 
  then
    echo -e "\n$1"
  fi

  echo -e "\n1) cut\n2) color\n3) perm\n4) style\n5) trim"
  echo -e "\nPlease select the number of the service you need:"
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-5] ) SERVICE;;
    *     ) MAIN_MENU "That was not a valid option. Please try again.";;
  esac
}

SERVICE(){
  # present the selected service by name
  SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED;")
  echo -e "You selected:$SERVICE_NAME"
  
  # request phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # find customer
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE';")
  # if customer doesn't exist
  if [[ -z $CUSTOMER_ID ]] 
  then
    # ask for name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # insert customer
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE';")
  fi
  CUSTOMER_NAME=$($PSQL "select name from customers where customer_id=$CUSTOMER_ID;")
  
  # ask for service time
  echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
  read SERVICE_TIME

  # insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  # message to the customer
  echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
}

EXIT() {
  echo -e "\nThank you for stopping in. Bye!\n"
}

MAIN_MENU
