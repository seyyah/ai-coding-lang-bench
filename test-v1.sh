#!/bin/bash

# miniplaylist v1 Test Script
rm -rf .miniplaylist
echo "Running tests..."

OUTPUT=$(python miniplaylist.py init)
if [[ "$OUTPUT" == *"Initialized empty playlist"* ]]; then echo "PASSED: init"; else echo "FAILED: init"; fi

OUTPUT=$(python miniplaylist.py create "Rock Listesi")
if [[ "$OUTPUT" == *"Playlist 'Rock Listesi' created."* ]]; then echo "PASSED: create"; else echo "FAILED: create"; fi

OUTPUT=$(python miniplaylist.py show "Rock Listesi")
if [[ "$OUTPUT" == *"Playlist is empty."* ]]; then echo "PASSED: show empty"; else echo "FAILED: show empty"; fi

OUTPUT=$(python miniplaylist.py show "Pop Listesi")
if [[ "$OUTPUT" == *"Playlist not found."* ]]; then echo "PASSED: show not found"; else echo "FAILED: show not found"; fi

rm -rf .miniplaylist
echo "Tests completed."