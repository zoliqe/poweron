// Copyright (c) 2017, Michal Karas. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:redstone/redstone.dart' as app;
import 'package:path/path.dart' as Path;
import 'package:shelf_static/shelf_static.dart';
import 'package:serial_port/serial_port.dart';


const String noop = '_';
const List<String> allowedOps = const ['om4aa' + noop + '1999', 'om3by' + noop + '1993'];
bool powerState = false;
String currentOp = noop;

String ttyUSB = '';
SerialPort arduino;


@app.Route("/who")
who() => currentOp.substring(0, currentOp.indexOf('_')).toUpperCase();

@app.Route("/state/:state/:who")
state(String state, String who) {
  print("state=${state}, who=${who} ${app.request.session}");
  if (who == null || (currentOp != noop && currentOp != who.toLowerCase()) || 
      !allowedOps.contains(who.toLowerCase())) {
    return "Not authorized: ${who}";
  }
  if (state == null || !['on', 'off'].contains(state)) {
    return "Invalid state: ${state}";
  }

  powerState = state == 'on';
  currentOp = powerState ? who : noop;
  sendPowerState();

  return powerState ? 'ON' : 'OFF'; // resp code 200
}

sendPowerState() async {
  await arduino.writeString(powerState ? 'H' : 'L');
}

listSerialPorts() async {
  final ports = await SerialPort.availablePortNames;
  print("Found ${ports.length} USB <-> serial ports");
  ports.forEach((port) => print(port));
  ttyUSB = ports.firstWhere((port) => port.contains("ttyUSB"), orElse: () => '');
  print("Using port: ${ttyUSB}");
  
  arduino = new SerialPort(ttyUSB);
  arduino.onRead.map(BYTES_TO_STRING).listen((data) => print("arduino: ${data}"));
  await arduino.open();
}

void main() {
  String scriptPath = Path.dirname(Path.fromUri(Platform.script));
  String pathToWeb = Path.normalize("${scriptPath}/../web");
  print("web path: ${pathToWeb}");
  print("allowed ops: ${allowedOps}");
  listSerialPorts();

  app.setShelfHandler(createStaticHandler(pathToWeb, 
                                          defaultDocument: "index.html", 
                                          serveFilesOutsidePath: true));

  app.setupConsoleLog();
  app.start(port: 1723);
}
