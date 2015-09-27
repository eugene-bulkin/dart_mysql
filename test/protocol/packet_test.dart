import 'package:dart_mysql/protocol/buffer_writer.dart';
import 'package:dart_mysql/protocol/capability_flags.dart';
import 'package:dart_mysql/protocol/packet.dart';
import 'package:test/test.dart';
import 'package:quiver/testing/equality.dart';

main() {
  group('Packet', () {
    test('throws error on malformed packets', () {
      expect(() => new Packet.fromBuffer([0x02]), throwsArgumentError);
      expect(
              () => new Packet.fromBuffer([0x02, 0x00, 0x00]), throwsArgumentError);
      expect(() => new Packet.fromBuffer([0x02, 0x00, 0x00, 0x05]),
      throwsArgumentError);
      expect(() => new Packet.fromBuffer([0x02, 0x00, 0x00, 0x05, 0x01]),
      throwsArgumentError);
    });

    test('outputs correct string', () {
      var sequenceId = 5;
      var payload = [0x01, 0x02];
      var packet = new Packet(2, sequenceId, payload);
      var expected = 'Packet($sequenceId)[${payload.join(' ')}]';

      expect(packet.toString(), equals(expected));
    });

    test('can be constructed from buffer', () {
      var buffer = [0x02, 0x00, 0x00, 0x05, 0x01, 0x02];
      var packet = new Packet.fromBuffer(buffer);
      expect(packet.length, equals(2));
      expect(packet.sequenceId, equals(5));
      expect(packet.payload, orderedEquals([0x01, 0x02]));
      expect(buffer, isEmpty);
    });

    test('creates correct byte data', () {
      var packet = new Packet(2, 5, [0x01, 0x02]);
      expect(packet.toBytes(),
      orderedEquals([0x02, 0x00, 0x00, 0x05, 0x01, 0x02]));
    });

    test('throws error on determining packet type if payload is empty.', () {
      var packet = new Packet(0, 0, []);
      expect(() => packet.isOK, throwsStateError);
      expect(() => packet.isERR, throwsStateError);
    });

    test('correctly determines packet type', () {
      var okPacket1 = new Packet(1, 0, [0x00]);
      var okPacket2 = new Packet(1, 0, [0xFE]);
      var errPacket = new Packet(1, 0, [0xFF]);

      expect(okPacket1.isOK, isTrue);
      expect(okPacket2.isOK, isTrue);
      expect(errPacket.isOK, isFalse);

      expect(okPacket1.isERR, isFalse);
      expect(okPacket2.isERR, isFalse);
      expect(errPacket.isERR, isTrue);
    });

    test('equality and hashCode', () {
      var packet1 = new Packet(2, 5, [0x01, 0x02]);
      var packet2 = new Packet(2, 5, [0x01, 0x02]);
      var packet3 = new Packet(2, 4, [0x01, 0x02]);
      var packet4 = new Packet(2, 4, [0x01, 0x02]);
      var packet5 = new Packet(2, 5, [0x03, 0x04]);
      var packet6 = new Packet(2, 5, [0x03, 0x04]);

      expect({
        'packet1': [packet1, packet2],
        'packet2': [packet3, packet4],
        'packet3': [packet5, packet6],
      }, areEqualityGroups);
    });
  });

  group('OKPacket', () {
    const affectedRows = 5;
    const lastInsertId = 1;
    const statusFlags = 0x0002;
    const numWarnings = 10;
    const info = 'foo bar';
    Packet packet;

    setUp(() {
      var writer = new BufferWriter();
      writer.writeInt1(0x00); // error packet
      writer.writeLenencInt(affectedRows);
      writer.writeLenencInt(lastInsertId);
      writer.writeInt2(statusFlags);
      writer.writeInt2(numWarnings);
      writer.writeString(info);
      packet = new Packet(writer.buffer.length, 0, writer.buffer);
    });

    test('fails on non-OK packets', () {
      expect(() => new OKPacket.fromPacket(new Packet(1, 0, [0xFF]), 0),
      throwsArgumentError);
    });

    test('can be created from Packet', () {
      var okPacket =
      new OKPacket.fromPacket(packet, CapabilityFlags.CLIENT_PROTOCOL_41);

      expect(okPacket.affectedRows, equals(affectedRows));
      expect(okPacket.lastInsertId, equals(lastInsertId));
      expect(okPacket.statusFlags, equals(statusFlags));
      expect(okPacket.numWarnings, equals(numWarnings));
      expect(okPacket.info, equals(info));
    });
  });

  group('ERRPacket', () {
    const errorCode = 5000;
    const sqlStateMarker = '#';
    const sqlState = 'foo\x00\x00';
    const errorMessage = 'bar baz';
    Packet packet;

    setUp(() {
      var writer = new BufferWriter();
      writer.writeInt1(0xFF); // error packet
      writer.writeInt2(errorCode);
      writer.writeFixedString(sqlStateMarker, 1);
      writer.writeFixedString(sqlState, 5);
      writer.writeString(errorMessage);
      packet = new Packet(writer.buffer.length, 0, writer.buffer);
    });

    test('fails on non-error packets', () {
      expect(() => new ERRPacket.fromPacket(new Packet(1, 0, [0x00]), 0),
      throwsArgumentError);
    });

    test('can be created from Packet', () {
      var errPacket = new ERRPacket.fromPacket(packet, 0);

      expect(errPacket.errorCode, equals(errorCode));
      expect(errPacket.sqlStateMarker, equals(sqlStateMarker));
      expect(errPacket.sqlState, equals(sqlState));
      expect(errPacket.errorMessage, equals(errorMessage));
    });

    test('outputs correct string', () {
      var errPacket = new ERRPacket.fromPacket(packet, 0);
      var expected = '#$errorCode ($sqlStateMarker$sqlState): $errorMessage';

      expect(errPacket.toString(), equals(expected));
    });
  });
}
