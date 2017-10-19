#!/bin/sh

#python3 server.py 2>&1 >>$DIR/log.txt &
#echo "Starting..."
export FLASK_APP="poweron.py" 
flask run --host=0.0.0.0 --port=1723 >poweron.log 2>&1
