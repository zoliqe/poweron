// Copyright (c) 2017, Michal Karas. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:serial_port/serial_port.dart';


bool powerState = false;
SerialPort arduino;


sendPowerState() async {
  if (arduino != null) {
    print("open ${arduino}");
    await arduino.open();
    print("state ${powerState}");
    await arduino.writeString(powerState ? 'H' : 'L');
    print("close ${arduino}");
    await arduino.close();
  }
}

invState(Timer t) {
  print("port ${arduino}");
  powerState = !powerState;
  // await sendPowerState();
}

listSerialPorts() async {
  final ports = await SerialPort.availablePortNames;
  print("Found ${ports.length} USB <-> serial ports");
  ports.forEach((port) => print(port));
  var ttyUSB = ports.firstWhere((port) => port.contains("ttyUSB"), orElse: () => '');
  
  if (ttyUSB.isNotEmpty) {
    print("Using port: ${ttyUSB}");
    arduino = new SerialPort(ttyUSB);
    // arduino.onRead.map(BYTES_TO_STRING).listen((data) => print("arduino: ${data}"));
    // await arduino.open();
  }
}

bool runn = true;
void stop() {
  runn = false;
}

main() async {
  await listSerialPorts();
    print("lport ${arduino}");
  // new Timer.periodic(const Duration(seconds: 5), invState);
  invState(null);
  sleep(const Duration(seconds: 5));
  invState(null);
  sleep(const Duration(seconds: 5));
  invState(null);
  sleep(const Duration(seconds: 5));
  invState(null);
  sleep(const Duration(seconds: 5));
  invState(null);
  sleep(const Duration(seconds: 5));
  invState(null);
  sleep(const Duration(seconds: 5));
  invState(null);
  sleep(const Duration(seconds: 5));
  invState(null);
  // new Timer(const Duration(minutes: 1), stop);
  // while (runn) {sleep(const Duration(seconds: 1));}
}
