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
}
