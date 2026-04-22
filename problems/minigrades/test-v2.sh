#!/bin/bash
python3 minigrades.py init > /dev/null
python3 minigrades.py add "Yemin" "100" > /dev/null
if python3 minigrades.py list | grep -q "Yemin"; then
    echo "✅ V2: Success."
else
    echo "❌ V2: Failed."
    exit 1
fi
