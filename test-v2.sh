#!/bin/bash

# miniplaylist v2 Test Script (Future commands)
rm -rf .miniplaylist
python miniplaylist.py init > /dev/null
python miniplaylist.py create "Karma" > /dev/null

echo "Running v2 tests..."

OUTPUT=$(python miniplaylist.py add "Karma" "Bohemian Rhapsody")
if [[ "$OUTPUT" == *"will be implemented"* ]]; then echo "PASSED: add (not implemented)"; else echo "FAILED: add"; fi

rm -rf .miniplaylist
echo "v2 Tests completed."