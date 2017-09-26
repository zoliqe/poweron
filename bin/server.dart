// Copyright (c) 2017, Michal Karas. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;

// import 'package:args/args.dart';
// import 'package:shelf/shelf.dart' as shelf;
// import 'package:shelf/shelf_io.dart' as io;
import 'package:redstone/redstone.dart' as app;
import 'package:path/path.dart' as Path;
import 'package:shelf_static/shelf_static.dart';

const String noop = '_';
const List<String> allowedOps = const ['om4aa' + noop + '1999'];
bool powerState = false;
String currentOp = noop;

@app.Route("/hello/:name")
helloWorld([String name = "World"]) => "Hello, ${name}";

@app.Route("/who")
who() => currentOp.substring(0, currentOp.indexOf('_')).toUpperCase();

@app.Route("/state/:state/:who")
state(String state, String who) {
  print("state=${state}, who=${who} ${app.request.session}");
  if (who == null || (currentOp != noop && currentOp != who.toLowerCase()) || 
      !allowedOps.contains(who.toLowerCase())) {
    return "Not authorized";
  }
  if (state == null || !['on', 'off'].contains(state)) {
    return "Invalid state";
  }
  powerState = state == 'on';
  currentOp = powerState ? who : noop;
  return powerState ? 'Powered ON' : 'Powered OFF';
}

void main() {
  String scriptPath = Path.dirname(Path.fromUri(Platform.script));
  String pathToWeb = Path.normalize("$scriptPath/../web");
  print("web path: ${pathToWeb}");

  app.setShelfHandler(createStaticHandler(pathToWeb, 
                                          defaultDocument: "index.html", 
                                          serveFilesOutsidePath: true));

  app.setupConsoleLog();
  app.start(port: 1723);
}

// void main(List<String> args) {
//   var parser = new ArgParser()
//     ..addOption('port', abbr: 'p', defaultsTo: '8080');

//   var result = parser.parse(args);

//   var port = int.parse(result['port'], onError: (val) {
//     stdout.writeln('Could not parse port value "$val" into a number.');
//     exit(1);
//   });

//   var handler = const shelf.Pipeline()
//       .addMiddleware(shelf.logRequests())
//       .addHandler(_echoRequest);

//   io.serve(handler, '0.0.0.0', port).then((server) {
//     print('Serving at http://${server.address.host}:${server.port}');
//   });
// }

// shelf.Response _echoRequest(shelf.Request request) {
//   return new shelf.Response.ok('Request for "${request.url}"');
// }
