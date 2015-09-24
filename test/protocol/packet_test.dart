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
