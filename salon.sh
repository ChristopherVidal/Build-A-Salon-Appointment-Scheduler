#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

DISPLAY_SERVICES(){

SERVICES_OFFERED=$($PSQL "SELECT service_id, name FROM services order by service_id")
echo "$SERVICES_OFFERED" | while read SERVICE_ID BAR NAME
do
  echo -e "$SERVICE_ID) "$NAME""
done

}

DISPLAY_SERVICES
read SERVICE_ID_SELECTED

until [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ && -n $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") ]]
do
  echo -e "\nI could not find that service. What would you like today?"
  DISPLAY_SERVICES
  read SERVICE_ID_SELECTED
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers where phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
FORMATTED_SERVICE_NAME=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
FORMATTED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')

echo -e "\nWhat time would you like your $FORMATTED_SERVICE_NAME, $FORMATTED_CUSTOMER_NAME?"
read SERVICE_TIME

CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone='$CUSTOMER_PHONE'")

ADD_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

if [[  $ADD_APPOINTMENT_RESULT = "INSERT 0 1" ]]
then
  FORMATTED_APPT_TIME=$(echo $SERVICE_TIME | sed -r 's/^ *| *$//g')
  echo -e "\nI have put you down for a $FORMATTED_SERVICE_NAME at $FORMATTED_APPT_TIME, $FORMATTED_CUSTOMER_NAME."
fi
