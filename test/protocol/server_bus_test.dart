import 'dart:io';

import 'package:dart_mysql/protocol/server_bus.dart';
import 'package:test/test.dart';
import 'package:dart_mysql/protocol/packet.dart';
import 'dart:async';

main() {
  const host = '127.0.0.1';
  const port = 55555;
  group('ServerBus', () {
    const packet1 = const Packet(5, 2, const [0x01, 0x02, 0x03, 0x04, 0x05]);
    const packet2 = const Packet(3, 1, const [0xA, 0xB, 0xC]);
    final List<int> buffer1 = packet1.toBytes();
    final List<int> buffer2 = packet2.toBytes();
    StreamController<Packet> controller;
    ServerBus bus;
    ServerSocket serverSocket;
    Socket socket;

    setUp(() async {
      controller = new StreamController<Packet>.broadcast(sync: true);
      serverSocket = await ServerSocket.bind(host, port);
      bus = new ServerBus(host, port, controller: controller);
      await bus.connected;
      socket = await serverSocket.first;
    });

    tearDown(() async {
      socket.destroy();
      await socket.close();

      await serverSocket.close();
    });

    test('processes buffers correctly', () async {
      socket.add(buffer1);
      socket.add(buffer2);

      var result1 = await controller.stream.first;
      var result2 = await controller.stream.first;

      expect(result1, equals(packet1));
      expect(result2, equals(packet2));
    }, timeout: new Timeout(const Duration(seconds: 5)));

    test('processes consecutive buffers correctly', () async {
      var combined = [];
      combined
        ..addAll(buffer1)
        ..addAll(buffer2);
      socket.add(combined);

      var result1 = await controller.stream.first;
      var result2 = await controller.stream.first;

      expect(result1, equals(packet1));
      expect(result2, equals(packet2));
    }, timeout: new Timeout(const Duration(seconds: 5)));

    test('sends packets correctly', () async {
      bus.sendPacket(packet1);

      expect(await socket.first, orderedEquals(buffer1));
    }, timeout: new Timeout(const Duration(seconds: 5)));

    test('ensure closing turns off subscriptions', () async {
      await bus.close();

      expect(controller.hasListener, isFalse);
    }, timeout: new Timeout(const Duration(seconds: 5)));
  });
}
