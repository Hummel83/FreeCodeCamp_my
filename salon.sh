#! /bin/bash

# Script to schedule salon appointments

# Function to show services
SHOW_SERVICES() {
  # List all available services
  SERVICES=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

echo -e "\n~~ Welcome to the Salon ~~\n"

# Prompt for service selection
echo "How can I help you?"
SHOW_SERVICES

read SERVICE_ID_SELECTED

# Check if service_id is valid
SERVICE_NAME_SELECTED=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
SERVICE_NAME_SELECTED=$(echo $SERVICE_NAME_SELECTED | sed 's/^[ \t]*//;s/[ \t]*$//')

# If no service found, show list again
while [[ -z $SERVICE_NAME_SELECTED ]]
do
  echo -e "\nI could not find that service. What would you like today?"
  SHOW_SERVICES
  read SERVICE_ID_SELECTED
  SERVICE_NAME_SELECTED=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  SERVICE_NAME_SELECTED=$(echo $SERVICE_NAME_SELECTED | sed 's/^[ \t]*//;s/[ \t]*$//')
done

# Prompt for phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^[ \t]*//;s/[ \t]*$//')

# If customer doesn't exist, get name and insert
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_RESULT=$(psql --username=freecodecamp --dbname=salon -t -c "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
fi

# Get customer_id
CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
CUSTOMER_ID=$(echo $CUSTOMER_ID | sed 's/^[ \t]*//;s/[ \t]*$//')

# Prompt for service time
echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
read SERVICE_TIME

# Insert appointment
INSERT_APPOINTMENT=$(psql --username=freecodecamp --dbname=salon -t -c "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

# Confirm appointment
echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
