#!/bin/bash

# Asigura folosirea corecta, un sigur argument trebuie trimis in script (o singura comanda)
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <command-name>"
  exit 1                              #indica eroarea
fi

COMMAND=$1                            #retine numele comenzii din argument
PID=$$                                #stocheaza pid-ul clientului
CONFIG_FILE="server_config"           #specifica fisierul care retine well known fifo

# Se asigura ca exista fisierul FIFO
if [[ ! -f $CONFIG_FILE ]]; then
  echo "Error: Configuration file '$CONFIG_FILE' not found."
  exit 1
fi

WELL_KNOWN_FIFO=$(cat "$CONFIG_FILE")     #citeste path-ul lui well known fifo

if [[ ! -p $WELL_KNOWN_FIFO ]]; then
  echo "Error: Server is not running or the FIFO is missing."
  exit 1
fi                                        #daca nu exista well known fifo atunci printeaza o eroare

# creaza un path pentru client unic FIFO
CLIENT_FIFO="/tmp/server-reply-$PID"
if [[ -p $CLIENT_FIFO ]]; then
  rm -f "$CLIENT_FIFO"
fi                                #sterge clientul fifo daca acesta deja exista

mkfifo "$CLIENT_FIFO"                 #aici creeaza fifo personalizat pentru client 

# asigura stergerea cererii clientului
trap 'rm -f "$CLIENT_FIFO"' EXIT

# trimite cererea serverului
echo "BEGIN-REQ [$PID: $COMMAND] END-REQ" > "$WELL_KNOWN_FIFO"
echo "Waiting for response from the server..."

# citeste  si afiseaza raspunsul serverului

if cat "$CLIENT_FIFO"; then
  echo "Response received."
else
  echo "Error: Failed to read response from server."
fi