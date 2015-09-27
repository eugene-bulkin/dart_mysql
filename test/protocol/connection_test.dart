import 'dart:async';
import 'dart:convert';

import 'package:dart_mysql/protocol/buffer_reader.dart';
import 'package:dart_mysql/protocol/capability_flags.dart';
import 'package:dart_mysql/protocol/command_type.dart';
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
    const authPluginName = 'mysql_native_password';
    const database = 'database';
    const username = 'test';
    const password = 'foo';
    const scramble = const [
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
    ];
    const correctHash = const [
      0xf0,
      0xeb,
      0xd4,
      0xd2,
      0x22,
      0xeb,
      0x8a,
      0x99,
      0xa7,
      0xca,
      0x16,
      0xed,
      0x1b,
      0x3c,
      0x69,
      0xc1,
      0xce,
      0x1b,
      0x8c,
      0xdd
    ];
    const authHandshakeBuffer = const [
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
    final authHandshakePacket =
        new Packet.fromBuffer(authHandshakeBuffer.toList(growable: true));
    ServerBus bus;
    StreamController controller;
    Connection conn;

    setUp(() async {
      controller = new StreamController<Packet>.broadcast(sync: true);
      bus = new FakeServerBus(controller);
      conn = new Connection.fromBus(bus, username);
    });

    test('throws error when connection missing bus or username', () {
      expect(() => new Connection.fromBus(null, username), throwsArgumentError);
      expect(
          () => new Connection.fromBus(
              new FakeServerBus(new StreamController<Packet>()), null),
          throwsArgumentError);
    });

    group('when parsing handshake', () {
      test('properly handles without auth', () {
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
            orderedEquals([
              0x64,
              0x76,
              0x48,
              0x40,
              0x49,
              0x2d,
              0x43,
              0x4a,
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
              0x3a
            ]));
      });

      test('properly handles with auth', () {
        var handshakeData = conn.parseHandshake(authHandshakePacket.payload);
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

      test('throws error on wrong protocol', () async {
        var connFuture = conn.connect();
        await bus.connected;
        controller.add(new Packet.fromBuffer([0x01, 0x00, 0x00, 0x00, 0x09]));
        expect(connFuture, throwsA(new isInstanceOf<UnsupportedError>()));
      }, timeout: new Timeout(const Duration(seconds: 5)));
    });

    group('hashes passwords correctly', () {
      test('with empty password', () {
        expect(Connection.hashPassword(null, []), orderedEquals([]));
      });

      test('with password', () {
        expect(Connection.hashPassword(password, scramble),
            orderedEquals(correctHash));
      });
    });

    group('when creating response', () {
      test('throws error if client protocol is < 4.1', () {
        var handshake =
            new HandshakeData(null, null, 0x00000000, null, null, null, null);
        expect(() => conn.makeResponse(handshake), throwsUnsupportedError);
      });

      test('correctly creates response without DB', () {
        var characterSet = 0x08;
        var handshake = new HandshakeData(null, null,
            CapabilityFlags.CLIENT_PROTOCOL_41, characterSet, null, null, null);
        var packet = conn.makeResponse(handshake);
        var reader = new BufferReader(packet.payload);

        var capabilities = reader.readInt4();
        expect(
            capabilities & CapabilityFlags.CLIENT_CONNECT_WITH_DB, equals(0));
        expect(reader.readInt4(), equals(0x01000000));
        expect(reader.readInt1(), equals(characterSet));
        reader.readBytes(23);
        expect(
            reader.readNullTerminatedString(), equals(UTF8.encode(username)));
      });

      test('correctly creates response with DB', () {
        var conn = new Connection.fromBus(bus, username, database: database);
        var characterSet = 0x08;
        var handshake = new HandshakeData(null, null,
            CapabilityFlags.CLIENT_PROTOCOL_41, characterSet, null, null, null);
        var packet = conn.makeResponse(handshake);
        var reader = new BufferReader(packet.payload);

        var capabilities = reader.readInt4();
        expect(capabilities & CapabilityFlags.CLIENT_CONNECT_WITH_DB,
            greaterThan(0));
        expect(reader.readInt4(), equals(0x01000000));
        expect(reader.readInt1(), equals(characterSet));
        reader.readBytes(23);
        expect(
            reader.readNullTerminatedString(), equals(UTF8.encode(username)));
        expect(
            reader.readNullTerminatedString(), equals(UTF8.encode(database)));
      });

      test('correctly creates response with password', () {
        var conn = new Connection.fromBus(bus, username, password: password);
        var characterSet = 0x08;
        var handshake = new HandshakeData(
            null,
            null,
            CapabilityFlags.CLIENT_PROTOCOL_41 |
                CapabilityFlags.CLIENT_SECURE_CONNECTION |
                CapabilityFlags.CLIENT_PLUGIN_AUTH,
            characterSet,
            null,
            scramble,
            authPluginName);
        var packet = conn.makeResponse(handshake);
        var reader = new BufferReader(packet.payload);

        var capabilities = reader.readInt4();
        expect(
            capabilities & CapabilityFlags.CLIENT_CONNECT_WITH_DB, equals(0));
        expect(reader.readInt4(), equals(0x01000000));
        expect(reader.readInt1(), equals(characterSet));
        reader.readBytes(23);
        expect(
            reader.readNullTerminatedString(), equals(UTF8.encode(username)));
        expect(reader.readBytes(reader.readInt1()), orderedEquals(correctHash));
      });

      test('correctly creates response with plugin name', () {
        var conn = new Connection.fromBus(bus, username, password: password);
        var characterSet = 0x08;
        var handshake = new HandshakeData(
            null,
            null,
            CapabilityFlags.CLIENT_PROTOCOL_41 |
                CapabilityFlags.CLIENT_SECURE_CONNECTION |
                CapabilityFlags.CLIENT_PLUGIN_AUTH,
            characterSet,
            null,
            scramble,
            authPluginName);
        var packet = conn.makeResponse(handshake);
        var reader = new BufferReader(packet.payload);

        var capabilities = reader.readInt4();
        expect(
            capabilities & CapabilityFlags.CLIENT_CONNECT_WITH_DB, equals(0));
        expect(reader.readInt4(), equals(0x01000000));
        expect(reader.readInt1(), equals(characterSet));
        reader.readBytes(23);
        expect(
            reader.readNullTerminatedString(), equals(UTF8.encode(username)));
        expect(reader.readBytes(reader.readInt1()), orderedEquals(correctHash));
        expect(reader.readNullTerminatedString(),
            equals(UTF8.encode(authPluginName)));
      });

      test('correctly creates response with all information', () {
        var conn = new Connection.fromBus(bus, username,
            password: password, database: database);
        var characterSet = 0x08;
        var handshake = new HandshakeData(
            null,
            null,
            CapabilityFlags.CLIENT_PROTOCOL_41 |
                CapabilityFlags.CLIENT_SECURE_CONNECTION |
                CapabilityFlags.CLIENT_PLUGIN_AUTH,
            characterSet,
            null,
            scramble,
            authPluginName);
        var packet = conn.makeResponse(handshake);
        var reader = new BufferReader(packet.payload);

        var capabilities = reader.readInt4();
        expect(capabilities & CapabilityFlags.CLIENT_CONNECT_WITH_DB,
            greaterThan(0));
        expect(reader.readInt4(), equals(0x01000000));
        expect(reader.readInt1(), equals(characterSet));
        reader.readBytes(23);
        expect(
            reader.readNullTerminatedString(), equals(UTF8.encode(username)));
        expect(reader.readBytes(reader.readInt1()), orderedEquals(correctHash));
        expect(
            reader.readNullTerminatedString(), equals(UTF8.encode(database)));
        expect(reader.readNullTerminatedString(),
            equals(UTF8.encode(authPluginName)));
      });
    });

    test('does handshake correctly', () async {
      var eventFuture = controller.stream.first;
      conn.doHandshake(authHandshakePacket);

      var expected =
          conn.makeResponse(conn.parseHandshake(authHandshakePacket.payload));

      expect(await eventFuture, equals(expected));
    }, timeout: new Timeout(const Duration(seconds: 5)));

    test('throws error when handshake fails', () async {
      var connFuture = conn.connect();
      await bus.connected;
      controller.add(authHandshakePacket);
      controller.add(new Packet(1, 0, [0xFF]));

      expect(connFuture, throwsStateError);
    }, timeout: new Timeout(const Duration(seconds: 5)));

    test('handles queries', () async {
      const query = 'foo';

      var connFuture = conn.connect();
      await bus.connected;
      controller.add(authHandshakePacket);
      controller.add(new Packet(1, 0, [0x00]));
      await connFuture;

      var packetFuture = controller.stream.first;
      var queryFuture = conn.query(query);
      var buf = [CommandType.COM_QUERY]
        ..addAll(UTF8.encode(query));
      var expectedPacket = new Packet(buf.length, 0, buf);
      expect(await packetFuture, equals(expectedPacket));

      // need to wait for the next event loop
      await new Future(() {
      });

      // OK_Packet to end query (we just want to test that process works when query handler is done).
      controller.add(new Packet(1, 0, [0x00]));

      expect(await queryFuture, isEmpty);
    }, timeout: new Timeout(const Duration(seconds: 5)));
  });
}
