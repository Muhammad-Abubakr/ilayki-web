#!/bin/bash

# Set the port
PORT=8080

# switch directories
cd build/web/

# Start the server
echo 'Server starting on port' $PORT '...'
python3 -m http.server $PORT &
