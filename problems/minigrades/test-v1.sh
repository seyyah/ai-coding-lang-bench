#!/bin/bash
python3 minigrades.py init > /dev/null
ADD_OUT=$(python3 minigrades.py add "Ahmet" "80")
if [[ "$ADD_OUT" == *"Added grade #1 for Ahmet"* ]]; then
    echo "✅ V1: Success."
else
    echo "❌ V1: Failed."
    exit 1
fi
