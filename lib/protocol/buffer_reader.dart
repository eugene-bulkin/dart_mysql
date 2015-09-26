library dart_mysql.protocol.buffer_reader;

import 'package:quiver/check.dart';

/// A processor which reads a buffer using MySQL data types.
class BufferReader {
  List<int> _buffer;

  int _ptr = 0;

  bool get hasMore => _ptr < _buffer.length;

  BufferReader(this._buffer);

  /// Reads [length] bytes from the buffer.
  List<int> readBytes(int length) {
    checkState(_ptr + length <= _buffer.length,
        message: 'attempted to read past end of buffer');
    var result = _buffer.sublist(_ptr, _ptr + length);
    _ptr += length;
    return result;
  }

  /// Reads a string<fix> from the buffer.
  ///
  /// See [MySQL Internals 14.1.1.2](http://dev.mysql.com/doc/internals/en/string.html#packet-Protocol::FixedLengthString).
  List<int> readFixedString(int length) => readBytes(length);

  /// Reads a string<NUL> from the buffer.
  ///
  /// See [MySQL Internals 14.1.1.2](http://dev.mysql.com/doc/internals/en/string.html#packet-Protocol::NulTerminatedString).
  ///
  /// Throws a [StateError] if a NUL byte is never read before reaching the end of a string.
  List<int> readNullTerminatedString() {
    try {
      var bytes = [];
      while (_buffer[_ptr] != 0x00) {
        bytes.add(_buffer[_ptr++]);
      }
      _ptr++;
      return bytes;
    } on RangeError catch (_) {
      throw new StateError('attempted to read past end of buffer');
    }
  }

  /// Reads a string<EOF> from the buffer.
  ///
  /// See [MySQL Internals 14.1.1.2](http://dev.mysql.com/doc/internals/en/string.html#packet-Protocol::RestOfPacketString).
  List<int> readEOFString() {
    var result = _buffer.sublist(_ptr);
    _ptr = _buffer.length;
    return result;
  }

  /// Reads a string<lenenc> from the buffer.
  ///
  /// See [MySQL Internals 14.1.1.2](http://dev.mysql.com/doc/internals/en/string.html#packet-Protocol::LengthEncodedString).
  List<int> readLenencString() {
    var length = readLenencInt();
    return readFixedString(length);
  }

  int _readInt(int length) {
    var bytes = readBytes(length);
    var total = 0;
    for (var i = 0, shift = 0; i < length; i++, shift += 8) {
      total += bytes[i] << shift;
    }
    return total;
  }

  /// Reads an int<1> from the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.1](http://dev.mysql.com/doc/internals/en/integer.html#fixed-length-integer). The
  /// bytes are stored in little-endian.
  int readInt1() => _readInt(1);

  /// Reads an int<2> from the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.1](http://dev.mysql.com/doc/internals/en/integer.html#fixed-length-integer). The
  /// bytes are stored in little-endian.
  int readInt2() => _readInt(2);

  /// Reads an int<3> from the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.1](http://dev.mysql.com/doc/internals/en/integer.html#fixed-length-integer). The
  /// bytes are stored in little-endian.
  int readInt3() => _readInt(3);

  /// Reads an int<4> from the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.1](http://dev.mysql.com/doc/internals/en/integer.html#fixed-length-integer). The
  /// bytes are stored in little-endian.
  int readInt4() => _readInt(4);

  /// Reads an int<6> from the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.1](http://dev.mysql.com/doc/internals/en/integer.html#fixed-length-integer). The
  /// bytes are stored in little-endian.
  int readInt6() => _readInt(6);

  /// Reads an int<8> from the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.1](http://dev.mysql.com/doc/internals/en/integer.html#fixed-length-integer). The
  /// bytes are stored in little-endian.
  int readInt8() => _readInt(8);

  /// Reads an int<lenenc> from the buffer.
  ///
  /// See [MySQL Internals 14.1.1.1.2](http://dev.mysql.com/doc/internals/en/integer.html#length-encoded-integer). This
  /// is a special type of length-encoded integer. The first byte signals how large the integer length is. The following
  /// bytes are stored in little-endian.
  ///
  /// Since a first byte of 0xFF is undefined, we throw a [StateError] if an int<lenenc> read is attempted with 0xFF as
  /// the first byte.
  int readLenencInt() {
    var firstByte = _buffer[_ptr++];
    if (firstByte < 0xfb) {
      return firstByte;
    }
    if (firstByte == 0xfc) {
      return readInt2();
    }
    if (firstByte == 0xfd) {
      return readInt3();
    }
    if (firstByte == 0xfe) {
      return readInt8();
    }
    throw new StateError(
        '0xFF as the first byte of an int<lenenc> is undefined.');
  }
}
