import 'dart:async';

import 'package:dart_mysql/protocol/connection.dart';
import 'package:dart_mysql/protocol/packet.dart';
import 'package:dart_mysql/protocol/server_bus.dart';
import 'package:dart_mysql/testing/fakes.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.message}');
  });

  group('Connection', () {
    const username = 'test';
    ServerBus bus;
    StreamController controller;
    Connection conn;

    setUp(() async {
      controller = new StreamController<Packet>(sync: true);
      bus = new FakeServerBus(controller);
      conn = new Connection(bus, username);
    });

    test('properly parses handshake without auth', () {
      const handshakeBuffer = const [
        0x36,
        0x00,
        0x00,
        0x00,
        0x0a,
        0x35,
        0x2e,
        0x35,
        0x2e,
        0x32,
        0x2d,
        0x6d,
        0x32,
        0x00,
        0x0b,
        0x00,
        0x00,
        0x00,
        0x64,
        0x76,
        0x48,
        0x40,
        0x49,
        0x2d,
        0x43,
        0x4a,
        0x00,
        0xff,
        0xf7,
        0x08,
        0x02,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x2a,
        0x34,
        0x64,
        0x7c,
        0x63,
        0x5a,
        0x77,
        0x6b,
        0x34,
        0x5e,
        0x5d,
        0x3a,
        0x00
      ];
      final handshakePacket =
      new Packet.fromBuffer(handshakeBuffer.toList(growable: true));
      var handshakeData = conn.parseHandshake(handshakePacket.payload);
      expect(handshakeData.serverVersion, equals('5.5.2-m2'));
      expect(handshakeData.connectionId, equals(0x0b));
      expect(handshakeData.capabilities, equals(0x0000f7ff));
      expect(handshakeData.characterSet, equals(8));
      expect(handshakeData.statusFlags, equals(0x02));
      expect(handshakeData.authPluginName, isNull);
      expect(
          handshakeData.authPluginData,
          orderedEquals([0x64, 0x76, 0x48, 0x40, 0x49, 0x2d, 0x43, 0x4a, 0x2a, 0x34, 0x64, 0x7c, 0x63, 0x5a, 0x77, 0x6b, 0x34, 0x5e, 0x5d, 0x3a]));
    });

    test('properly parses handshake with auth', () {
      const handshakeBuffer = const [
        0x50,
        0x00,
        0x00,
        0x00,
        0x0a,
        0x35,
        0x2e,
        0x36,
        0x2e,
        0x34,
        0x2d,
        0x6d,
        0x37,
        0x2d,
        0x6c,
        0x6f,
        0x67,
        0x00,
        0x56,
        0x0a,
        0x00,
        0x00,
        0x52,
        0x42,
        0x33,
        0x76,
        0x7a,
        0x26,
        0x47,
        0x72,
        0x00,
        0xff,
        0xff,
        0x08,
        0x02,
        0x00,
        0x0f,
        0xc0,
        0x15,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x2b,
        0x79,
        0x44,
        0x26,
        0x2f,
        0x5a,
        0x5a,
        0x33,
        0x30,
        0x35,
        0x5a,
        0x47,
        0x00,
        0x6d,
        0x79,
        0x73,
        0x71,
        0x6c,
        0x5f,
        0x6e,
        0x61,
        0x74,
        0x69,
        0x76,
        0x65,
        0x5f,
        0x70,
        0x61,
        0x73,
        0x73,
        0x77,
        0x6f,
        0x72,
        0x64,
        0x00
      ];
      final handshakePacket =
      new Packet.fromBuffer(handshakeBuffer.toList(growable: true));
      var handshakeData = conn.parseHandshake(handshakePacket.payload);
      expect(handshakeData.serverVersion, equals('5.6.4-m7-log'));
      expect(handshakeData.connectionId, equals(0x0a56));
      expect(handshakeData.capabilities, equals(0xc00fffff));
      expect(handshakeData.characterSet, equals(8));
      expect(handshakeData.statusFlags, equals(0x02));
      expect(handshakeData.authPluginName, equals('mysql_native_password'));
      expect(
          handshakeData.authPluginData,
          orderedEquals([
            0x52,
            0x42,
            0x33,
            0x76,
            0x7a,
            0x26,
            0x47,
            0x72,
            0x2b,
            0x79,
            0x44,
            0x26,
            0x2f,
            0x5a,
            0x5a,
            0x33,
            0x30,
            0x35,
            0x5a,
            0x47
          ]));
    });

    test('throws error on wrong protocol for handshake', () async {
      controller.add(new Packet.fromBuffer([0x01, 0x00, 0x00, 0x00, 0x09]));
      expect(conn.connect(), throwsA(new isInstanceOf<UnsupportedError>()));
    });
  });
}
