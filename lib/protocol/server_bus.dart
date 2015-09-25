library dart_mysql.protocol.server_bus;

import 'dart:io';
import 'dart:async';

import 'package:dart_mysql/protocol/packet.dart';
import 'package:logging/logging.dart';

/// An event bus used for receiving packets from the server and sending packets from the client.
class ServerBus {
  final _logger = new Logger('dart_mysql.protocol.ServerBus');

  Socket _socket;

  StreamSubscription _bufferSubscription;

  final StreamController _controller;

  final String host;

  final int port;

  Future<bool> _connected;

  /// A future denoting when the socket has been connected to.
  Future<bool> get connected => _connected;

  /// The stream of [Packet]s parsed from the server.
  Stream<Packet> get stream => _controller.stream;

  ServerBus(this.host, this.port, {StreamController controller})
  : _controller = (controller == null)
  ? new StreamController<Packet>.broadcast()
  : controller {
    var completer = new Completer();
    _connected = completer.future;
    Socket.connect(host, port).then((socket) async {
      _socket = socket;
      completer.complete(true);
      _bufferSubscription = _socket.listen(processBuffer, onDone: () async {
        _logger.finest('Socket closed.');
        await close();
      });
    }, onError: completer.completeError);
  }

  /// Processes a byte buffer sent by the socket. This parses the buffer into packet(s) and emits them on the event
  /// controller.
  void processBuffer(List<int> buffer) {
    var bufferCopy = buffer.toList(growable: true);
    while (bufferCopy.isNotEmpty) {
      _controller.add(new Packet.fromBuffer(bufferCopy));
    }
  }

  /// Sends a [Packet] over the socket to the server.
  void sendPacket(Packet packet) {
    var buffer = packet.toBytes();
    _socket.add(buffer);
  }

  /// Closes all connections and subscriptions.
  Future close() async {
    _logger.finest('Closing ServerBus.');
    await _controller.close();
    if (_socket != null) {
      await _socket.close();
      _socket = null;
    }
    if (_bufferSubscription != null) {
      await _bufferSubscription.cancel();
      _bufferSubscription = null;
    }
  }
}
