#!/usr/bin/python3
import os
import serial
from serial.tools import list_ports

from operator import attrgetter
from sanic import Sanic
from sanic.log import log
from sanic import response
from sanic.exceptions import ServerError

app = Sanic(__name__)
noop = "_"
acl = ("om4aa" + noop + "1999", "om3by" + noop + "1993")
who = noop
state = False
arduino = None

@app.route("/")
def main_request(request):
    return response.file(os.path.abspath("web/index.html"))

@app.route("/who")
def who_request(request):
    global who
    return response.text(who[0:who.find(noop)].upper())

@app.route("/state/<req_state>/<req_who>")
def state_request(request, req_state, req_who):
    global who, state
    print('req_state=' + req_state + ', req_who=' + req_who)
    if req_who is None or (who != noop and who != req_who.lower()) or req_who.lower() not in acl:
        return response.text("Not authorized: %s" % req_who)
    if req_state is None or req_state not in ('on', 'off'):
        return response.text("Bad state: %s" % req_state)

    state = req_state == 'on'
    who = req_who.lower() if state else noop

    if arduino != None:
        arduino.write(b'H' if state else b'L')
    return response.text('ON' if state else 'OFF')


def connect_arduino():
    global arduino
    ports = sorted(list_ports.comports(), key=attrgetter('device'))
    print(["Found port: %s %s" % (p.device, p.hwid) for p in ports])
    arduino = serial.Serial(ports[0].device, 9600)
    print("Using port %s" % arduino.name)


if __name__ == '__main__':
    connect_arduino()
    app.run(host='0.0.0.0', port=1723, debug=True)

