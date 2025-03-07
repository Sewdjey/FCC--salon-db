#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"



MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi  

    #GET AVAILABLE SERVICES
    SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")

    # DISPLAY SERVICES
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done

  read SERVICE_ID_SELECTED
  # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid number."
    else
      #GET SERVICE ID 
      SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
      if [[ -z $SERVICE_ID ]]
      then
        MAIN_MENU "That is not a valid number."
      else
      # GET CUSTOMER INFO
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name from customers WHERE phone='$CUSTOMER_PHONE'")
       # if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get new customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      fi

      #GET CUSTOMER ID
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
      # GET SERVICE NAME
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID'")
    
      # GET APPOINTMENT TIME
      echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/^ *//'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
      read SERVICE_TIME

      # INSERT APPOINTMENT
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/^ *//') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

      fi
    fi
 
}


MAIN_MENU
