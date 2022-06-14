import 'dart:io';
import 'dart:typed_data';

void initServer() async {
  // bind the socket server to an address and port
  final server = await ServerSocket.bind(InternetAddress('0.0.0.0'), 4567);

  // listen for clent connections to the server
  server.listen((client) {
    handleConnection(client);
  });
  connectTest();
}

void connectTest() async {
  final socket = await Socket.connect(InternetAddress('0.0.0.0'), 4567);
  socket.listen((event) {
    final message = String.fromCharCodes(event);
    print('Server: $message');
  });
  // socket.asStream().listen((event) {
  //   print(event);
  // });
  // socket.then((socket) {
  socket.write('Knock, knock.');
  await Future.delayed(const Duration(seconds: 1));
  socket.write('mamad');
  await Future.delayed(const Duration(seconds: 1));
  await Future.delayed(const Duration(seconds: 1));
  print('server closed');
  // socket.close();
  // });
}

void handleConnection(Socket client) {
  print('Connection from'
      ' ${client.remoteAddress.address}:${client.remotePort}');

  // listen for events from the client
  client.listen(
    // handle data from the client
    (Uint8List data) async {
      await Future.delayed(Duration(seconds: 1));
      final message = String.fromCharCodes(data);
      print('Client: $message');
      if (message == 'Knock, knock.') {
        client.write('Who is there?');
      } else if (message.length < 10) {
        client.write('$message who?');
      } else {
        client.write('Very funny.');
        await Future.delayed(const Duration(seconds: 1));
        client.close();
      }
    },

    // handle errors
    onError: (error) {
      print(error);
      client.close();
    },

    // handle the client closing the connection
    onDone: () {
      print('Client left');
      client.close();
    },
  );
}
