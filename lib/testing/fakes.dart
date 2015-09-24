library dart_mysql.testing.fakes;

import 'dart:async';

import 'package:dart_mysql/protocol/server_bus.dart';
import 'package:dart_mysql/protocol/packet.dart';

class FakeServerBus implements ServerBus {
  final StreamController<Packet> _controller;

  Future<bool> get connected => new Future.value(true);

  Stream<Packet> get stream => _controller.stream;

  FakeServerBus(this._controller);

  void sendPacket(Packet packet) => _controller.add(packet);

  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
