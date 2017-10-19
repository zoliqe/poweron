#!/usr/bin/python3
import os
import serial
import argparse
from serial.tools import list_ports

from operator import attrgetter
from flask import Flask

# declare device to be used, leave None to autodetect first serial port
USE_DEVICE = None#'/dev/ttyUSB0'

app = Flask(__name__)
noop = "_"
acl = ("om4aa" + noop + "1999", "om3by" + noop + "1993")
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
    if arduino and who != noop:
        arduino.reset_input_buffer()
        arduino.write(b'N')
        resp = arduino.read()
        arduino.reset_input_buffer()
        if resp != b'H': # reset who when inactive
            print("reseting session for long inactive who=%s" % who)
            who = noop
    return who[0:who.find(noop)].upper()

@app.route("/state/<req_state>/<req_who>")
def state_request(req_state, req_who):
    global who, state
    #print('req_state=' + req_state + ', req_who=' + req_who)
    if req_who is None or (who != noop and who != req_who.lower()) or req_who.lower() not in acl:
        return "Not authorized: %s" % req_who
    if req_state is None or req_state not in ('on', 'off'):
        return "Bad state: %s" % req_state

    prev = state
    state = req_state == 'on'
    who = req_who.lower() if state else noop
    result = 'ON' if state else 'OFF'
    if state != prev: # change detected
        print("change state=%s who=%s" % (result, req_who))

    if arduino:
        arduino.write(b'H' if state else b'L')
    return result


def connect_arduino(device):
    global arduino
    if device is None:
        print('No port defined, trying to determine first comport...')
        ports = sorted(list_ports.comports(), key=attrgetter('device')) # this may not be working on raspberrypi
        print(["Found port: %s %s" % (p.device, p.hwid) for p in ports])
        if ports and len(ports) > 0:
            device = ports[0].device
    if device:
        arduino = serial.Serial(device, 9600, timeout=3)
    if arduino:
        print("Using port %s" % arduino.name)
        arduino.write(b'L')



#if __name__ == '__main__':
# parser = argparse.ArgumentParser()
# parser.add_argument('-d', '--device', help='serial device where is Arduino board connected (eg. /dev/ttyUSB0)')
# args = parser.parse_args()
connect_arduino(USE_DEVICE)
#    app.run(host='0.0.0.0', port=1723, debug=True)

