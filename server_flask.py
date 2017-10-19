#!/usr/bin/python3
import os
import serial
import argparse
from serial.tools import list_ports

from operator import attrgetter
from flask import Flask

app = Flask(__name__)
noop = "_"
acl = ("om4aa" + noop + "1999")
who = noop
state = False
arduino = None

@app.route("/")
def main_request():
    with open(os.path.abspath("main.html"), 'r') as f:
        data = f.read()
    return data

@app.route("/who")
def who_request():
    global who
    return who[0:who.find(noop)].upper()

@app.route("/state/<req_state>/<req_who>")
def state_request(req_state, req_who):
    global who, state
    print('req_state=' + req_state + ', req_who=' + req_who)
    if req_who is None or (who != noop and who != req_who.lower()) or req_who.lower() not in acl:
        return "Not authorized: %s" % req_who
    if req_state is None or req_state not in ('on', 'off'):
        return "Bad state: %s" % req_state

    state = req_state == 'on'
    who = req_who.lower() if state else noop

    if arduino != None:
        arduino.write(b'H' if state else b'L')
    return 'ON' if state else 'OFF'


def connect_arduino(device):
    global arduino
    if device is None:
        print('No port defined, trying to determine first comport...')
        ports = sorted(list_ports.comports(), key=attrgetter('device')) # this may not be working on raspberrypi
        print(["Found port: %s %s" % (p.device, p.hwid) for p in ports])
        device = ports[0].device
    arduino = serial.Serial(device, 9600)
    print("Using port %s" % arduino.name)


#if __name__ == '__main__':
parser = argparse.ArgumentParser()
parser.add_argument('-d', '--device', 'serial device where is Arduino board connected (eg. /dev/ttyUSB0)')
args = parser.parse_args()
connect_arduino(args.device)
#    app.run(host='0.0.0.0', port=1723, debug=True)

