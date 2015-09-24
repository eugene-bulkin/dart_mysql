import 'package:dart_mysql/protocol/packet.dart';
import 'package:test/test.dart';

main() {
  group('Packet', () {
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
      expect(packet.toBytes(), orderedEquals([0x02, 0x00, 0x00, 0x05, 0x01, 0x02]));
    });
  });
}
