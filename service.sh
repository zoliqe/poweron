#!/bin/sh

DIR=/opt/poweron
cd $DIR
#python3 server.py 2>&1 >>$DIR/log.txt &
echo "Starting poweron server_flask.py..."
FLASK_APP=server_flask.py flask run --host=0.0.0.0 --port=1723 >>server_flask.log 2>&1 &
