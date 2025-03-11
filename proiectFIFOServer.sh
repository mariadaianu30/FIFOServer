#!/bin/bash

CONFIG_FILE="server_config"     #declara o variabila CONFIG_FILE care stocheaza numele well-known fifo
echo "/tmp/well-known-fifo" > "$CONFIG_FILE"    #stabileste path-ul lui well known fifo
WELL_KNOWN_FIFO=$(cat "$CONFIG_FILE")           #citeste continutul din CONFIG_FILE in variabila WELL_KNOWN_FIFO

# creeaza fisierul FIFO daca acesta nu exista
if [[ ! -p $WELL_KNOWN_FIFO ]]; then
  mkfifo "$WELL_KNOWN_FIFO"
fi

echo "Server is running and waiting for requests..."      #textul indica faptul ca server-ul e gata sa proceseze request-uri de la clienti

cleanup() {                                               #defineste o functie care sa sterge cererea clientului
  echo "Cleaning up FIFOs..."
  rm -f "$WELL_KNOWN_FIFO"
  exit
}

trap cleanup INT TERM EXIT                                #apeleaza cleanup cand script-ul primeste INT(intrerupere de semnal), TERM( termination signal), EXIT(cand script-ul se termina)

while true; do                                            #creeaza un loop infinit care tine server-ul ruland
  if read -r request < "$WELL_KNOWN_FIFO"; then           #citeste o cerere din WELL_KNOWN_FIFO
    echo "Received request: $request"                     #
    PID=$(echo "$request" | grep -oP '(?<=BEGIN-REQ \[)\d+(?=:)') #utilizeaza greo ca sa extraga PID(id-ul clientului) si COMMAND (comanda pentru care cere manualul)
    COMMAND=$(echo "$request" | grep -oP '(?<=: ).*(?=\] END-REQ)')

    if [[ -n $PID && -n $COMMAND ]]; then                 #verifica daca PID-ul si comanda sunt valide
      CLIENT_FIFO="/tmp/server-reply-$PID"                #construieste un client fifo path bazat pe pid
      
      #daca nu exista clientul, il creeaza
      if [[ ! -p $CLIENT_FIFO ]]; then
        mkfifo "$CLIENT_FIFO"
      fi

      # trimite raspunsul in subshell ca sa evite blocarea
      (
        timeout 10 man "$COMMAND" > "$CLIENT_FIFO" 2>/dev/null || echo "Command '$COMMAND' not found." > "$CLIENT_FIFO"
        echo "Response sent to $CLIENT_FIFO for command '$COMMAND'."
        rm -f "$CLIENT_FIFO"
      ) &

      #afiseaza mesaj predestinat erorii cauzat de formatul invalid
    else
      echo "Invalid request format: $request"
    fi
 #inchide primul if si inchide loop-ul, asteptand alta cerere
  fi
done