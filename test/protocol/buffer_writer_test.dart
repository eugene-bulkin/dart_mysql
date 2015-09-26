import 'package:dart_mysql/protocol/buffer_writer.dart';
import 'package:test/test.dart';

main() {
  group('BufferWriter', () {
    BufferWriter writer;

    setUp(() {
      writer = new BufferWriter();
    });

    test('throws error if trying to write an int bigger than desired length', () {
      expect(() => writer.writeInt1(0x100), throwsArgumentError);
      expect(() => writer.writeLenencInt(1 << 65), throwsArgumentError);
    });

    test('throws error if trying to write an int less than 0', () {
      expect(() => writer.writeInt1(-1), throwsArgumentError);
      expect(() => writer.writeLenencInt(-1), throwsArgumentError);
    });

    test('fills buffer', () {
      writer.fill(3);
      writer.fill(3, value: 5);
      expect(writer.buffer, orderedEquals([0, 0, 0, 5, 5, 5]));
    });

    test('writes int<1>', () {
      writer.writeInt1(0x30);
      expect(writer.buffer, orderedEquals([0x30]));
    });

    test('writes int<2>', () {
      writer.writeInt2(0xABCD);
      writer.writeInt2(0xAB);
      expect(writer.buffer, orderedEquals([0xCD, 0xAB, 0xAB, 0x00]));
    });

    test('writes int<3>', () {
      writer.writeInt3(0xABCDEF);
      writer.writeInt3(0xAB);
      expect(writer.buffer, orderedEquals([0xEF, 0xCD, 0xAB, 0xAB, 0x00, 0x00]));
    });

    test('writes int<4>', () {
      writer.writeInt4(0xABCDEF98);
      writer.writeInt4(0xAB);
      expect(writer.buffer, orderedEquals([0x98, 0xEF, 0xCD, 0xAB, 0xAB, 0x00, 0x00, 0x00]));
    });

    test('writes int<6>', () {
      writer.writeInt6(0xABCDEF987654);
      expect(writer.buffer, orderedEquals([0x54, 0x76, 0x98, 0xEF, 0xCD, 0xAB]));
    });

    test('writes int<8>', () {
      writer.writeInt8(0xABCDEF9876543210);
      expect(writer.buffer, orderedEquals([0x10, 0x32, 0x54, 0x76, 0x98, 0xEF, 0xCD, 0xAB]));
    });

    group('writes int<lenenc>', () {
      test('for n < 251', () {
        writer.writeLenencInt(0x00);
        writer.writeLenencInt(0xf0);
        expect(writer.buffer, orderedEquals([0x00, 0xf0]));
      });

      test('for 251 <= n < 2^16', () {
        writer.writeLenencInt(0xfb);
        writer.writeLenencInt(0xff);
        expect(writer.buffer, orderedEquals([0xfc, 0xfb, 0x00,
        0xfc, 0xff, 0x00]));
      });

      test('for 2^16 <= n < 2^24', () {
        writer.writeLenencInt(0x100000);
        writer.writeLenencInt(0xffff01);
        expect(writer.buffer, orderedEquals([0xfd, 0x00, 0x00, 0x10,
        0xfd, 0x01, 0xff, 0xff]));
      });

      test('for 2^24 <= n < 2^64', () {
        writer.writeLenencInt(0x10000000);
        writer.writeLenencInt(0xffffffffffff);
        expect(writer.buffer, orderedEquals([0xfe, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00,
        0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00]));
      });
    });

    test('writes string<fix>', () {
      writer.writeFixedString('foo', 5);
      expect(writer.buffer, orderedEquals([0x66, 0x6f, 0x6f, 0x00, 0x00]));
    });

    test('writes string<EOF>', () {
      writer.writeString('foo');
      expect(writer.buffer, orderedEquals([0x66, 0x6f, 0x6f]));
    });

    test('writes string<lenenc>', () {
      writer.writeLenencString('foo');
      expect(writer.buffer, orderedEquals([3, 0x66, 0x6f, 0x6f]));
    });

    test('writes string<NUL>', () {
      writer.writeNullTerminatedString('foo');
      expect(writer.buffer, orderedEquals([0x66, 0x6f, 0x6f, 0x00]));
    });
  });
}
