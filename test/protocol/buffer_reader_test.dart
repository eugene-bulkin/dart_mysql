import 'package:dart_mysql/protocol/buffer_reader.dart';
import 'package:test/test.dart';

main() {
  group('BufferReader', () {
    List<int> buffer;
    setUp(() {
      buffer = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08];
    });

    test('correctly determines when there is more buffer to read', () {
      var reader = new BufferReader([0, 1, 2]);
      expect(reader.hasMore, isTrue);

      reader.readBytes(2);
      expect(reader.hasMore, isTrue);

      reader.readBytes(1);
      expect(reader.hasMore, isFalse);
    });

    test('throws error when reading int past end of buffer', () {
      var reader = new BufferReader(buffer);
      expect(() => reader.readInt8(), returnsNormally);
      expect(() => reader.readInt1(), throwsStateError);
    });

    test('reads string<fix>', () {
      const len = 3;
      var reader = new BufferReader(buffer);
      expect(
          reader.readFixedString(len), orderedEquals(buffer.sublist(0, len)));
    });

    test('reads string<EOF>', () {
      var reader = new BufferReader(buffer);
      expect(reader.readEOFString(), orderedEquals(buffer));
    });

    test('reads string<lenenc>', () {
      const hexString = const [0x03, 0x66, 0x6f, 0x6f];
      var reader = new BufferReader(hexString);
      expect(reader.readLenencString(), orderedEquals(hexString.sublist(1)));
    });

    test('reads string<NUL>', () {
      const hexString = const [0x66, 0x6f, 0x6f, 0x00];
      var reader = new BufferReader(hexString);
      expect(reader.readNullTerminatedString(),
          orderedEquals(hexString.sublist(0, hexString.length - 1)));
    });

    test('throws when string<NUL> if no null byte occurs', () {
      const hexString = const [0x66, 0x6f, 0x6f];
      var reader = new BufferReader(hexString);
      expect(() => reader.readNullTerminatedString(), throwsStateError);
    });

    test('reads int<1>', () {
      var reader = new BufferReader(buffer);
      expect(reader.readInt1(), equals(0x01));
    });

    test('reads int<2>', () {
      var reader = new BufferReader(buffer);
      expect(reader.readInt2(), equals(0x0201));
    });

    test('reads int<3>', () {
      var reader = new BufferReader(buffer);
      expect(reader.readInt3(), equals(0x030201));
    });

    test('reads int<4>', () {
      var reader = new BufferReader(buffer);
      expect(reader.readInt4(), equals(0x04030201));
    });

    test('reads int<6>', () {
      var reader = new BufferReader(buffer);
      expect(reader.readInt6(), equals(0x060504030201));
    });

    test('reads int<8>', () {
      var reader = new BufferReader(buffer);
      expect(reader.readInt8(), equals(0x0807060504030201));
    });

    group('reads int<lenenc>', () {
      test('with 1 byte', () {
        var reader = new BufferReader([0xf0, 0xff, 0xff]);
        expect(reader.readLenencInt(), equals(0xf0));
      });

      test('with 3 bytes', () {
        var reader = new BufferReader([0xfc, 0x01, 0x02]);
        expect(reader.readLenencInt(), equals(0x0201));
      });

      test('with 4 bytes', () {
        var reader = new BufferReader([0xfd, 0x01, 0x02, 0x03]);
        expect(reader.readLenencInt(), equals(0x030201));
      });

      test('with 9 bytes', () {
        var reader = new BufferReader(
            [0xfe, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]);
        expect(reader.readLenencInt(), equals(0x0807060504030201));
      });

      test('with error if first byte is 0xff', () {
        var reader = new BufferReader([0xff, 0xff, 0xff]);
        expect(() => reader.readLenencInt(), throwsStateError);
      });
    });
  });
}
