#!/bin/bash

cargo run -F testing &
CARGO_PID=$!
echo "Serveur lancé (PID=$CARGO_PID), attente de l'ouverture du port 9345..."

for i in {1..60}; do
    if nc -z 127.0.0.1 9345; then
        echo "✅ Port 9345 ouvert, lancement des tests Python."
        python3 example/testing.py
        kill $CARGO_PID
        exit 0
    fi
    sleep 1
done

echo "⛔ Le port 9345 n'a pas été ouvert dans les temps."
kill $CARGO_PID
exit 1