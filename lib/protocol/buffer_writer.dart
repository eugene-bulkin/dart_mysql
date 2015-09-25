library dart_mysql.protocol.buffer_writer;

import 'dart:convert';

import 'package:quiver/check.dart';

/// A processor which writes a buffer using MySQL data types.
class BufferWriter {
  final List<int> buffer = [];

  void _writeInt(int length, int value) {
    checkArgument(value < 1 << (8 * length) && value >= 0,
    message: '$value out of range for int<$length>.');
    var i = 0;
    while (i < length) {
      buffer.add(value % 256);
      value >>= 8;
      i++;
    }
  }

  /// Adds [length] bits of [value] to buffer.
  void fill(int length, {int value: 0}) {
    var pos = buffer.length;
    buffer.addAll(new List<int>(length));
    buffer.fillRange(pos, pos + length, value);
  }

  /// Writes an int<1> to the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.1](http://dev.mysql.com/doc/internals/en/integer.html#fixed-length-integer). The
  /// bytes are stored in little-endian.
  void writeInt1(int value) => _writeInt(1, value);

  /// Writes an int<3> to the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.1](http://dev.mysql.com/doc/internals/en/integer.html#fixed-length-integer). The
  /// bytes are stored in little-endian.
  void writeInt2(int value) => _writeInt(2, value);

  /// Writes an int<4> to the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.1](http://dev.mysql.com/doc/internals/en/integer.html#fixed-length-integer). The
  /// bytes are stored in little-endian.
  void writeInt3(int value) => _writeInt(3, value);

  /// Writes an int<5> to the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.1](http://dev.mysql.com/doc/internals/en/integer.html#fixed-length-integer). The
  /// bytes are stored in little-endian.
  void writeInt4(int value) => _writeInt(4, value);

  /// Writes an int<7> to the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.1](http://dev.mysql.com/doc/internals/en/integer.html#fixed-length-integer). The
  /// bytes are stored in little-endian.
  void writeInt6(int value) => _writeInt(6, value);

  /// Writes an int<8> to the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.1](http://dev.mysql.com/doc/internals/en/integer.html#fixed-length-integer). The
  /// bytes are stored in little-endian.
  void writeInt8(int value) => _writeInt(8, value);

  /// Writes an int<lenenc> to the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.2](http://dev.mysql.com/doc/internals/en/integer.html#length-encoded-integer). This
  /// is a special type of length-encoded integer. The first byte signals how large the integer length is. The following
  /// bytes are stored in little-endian.
  void writeLenencInt(int value) {
    checkArgument(value < 1 << 64 && value >= 0,
    message: '$value out of range for int<lenenc>.');
    if (value < 251) {
      buffer.add(value);
    } else if (value < 1 << 16) {
      buffer.add(0xFC);
      writeInt2(value);
    } else if (value < 1 << 24) {
      buffer.add(0xFD);
      writeInt3(value);
    } else {
      buffer.add(0xFE);
      writeInt8(value);
    }
  }

  /// Writes [length] bytes to the buffer.
  void writeBytes(List<int> bytes) => buffer.addAll(bytes);

  /// Writes a string<fix> or string<EOF> to the buffer.
  ///
  /// See [MySQL Internals 14.1.1.2](http://dev.mysql.com/doc/internals/en/string.html#packet-Protocol::FixedLengthString).
  void writeString(String string) => writeBytes(UTF8.encode(string));

  /// Writes a string<lenenc> to the buffer.
  ///
  /// See [MySQL Internals 14.1.1.2](http://dev.mysql.com/doc/internals/en/string.html#packet-Protocol::LengthEncodedString).
  void writeLenencString(String string) {
    writeLenencInt(string.length);
    writeString(string);
  }

  /// Writes a string<NUL> to the buffer.
  ///
  /// See [MySQL Internals 14.1.1.2](http://dev.mysql.com/doc/internals/en/string.html#packet-Protocol::NulTerminatedString).
  void writeNullTerminatedString(String string) {
    writeString(string);
    writeBytes([0x00]);
  }
}
