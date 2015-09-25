library dart_mysql.protocol.packet;

import 'package:dart_mysql/protocol/buffer_reader.dart';
import 'package:dart_mysql/protocol/buffer_writer.dart';
import 'package:quiver/check.dart';
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';

/// A MySQL client/server protocol packet.
class Packet {
  /// The length of the packet.
  final int length;

  /// The sequence ID of the packet.
  final int sequenceId;

  /// The byte-array corresponding to the payload.
  final List<int> payload;

  const Packet(this.length, this.sequenceId, this.payload);

  /// Creates a new packet from a buffer. Modifies the buffer by removing the packet itself (so one can run
  /// [new Packet.fromBuffer] multiple times to get all packets).
  ///
  /// See [MySQL Internals 14.1.2](http://dev.mysql.com/doc/internals/en/mysql-packet.html) for details.
  factory Packet.fromBuffer(List<int> buffer) {
    int payloadLength;
    int sequenceId;
    List<int> payload;
    var reader = new BufferReader(buffer);
    try {
      payloadLength = reader.readInt3();
    } on StateError catch (_) {
      throw new ArgumentError('Corrupted buffer: insufficient length bytes.');
    }
    try {
      sequenceId = reader.readInt1();
    } on StateError catch (_) {
      throw new ArgumentError('Corrupted buffer: missing sequence ID.');
    }
    try {
      payload = reader.readBytes(payloadLength);
    } on StateError catch (_) {
      throw new ArgumentError('Corrupted buffer: missing portion of payload.');
    }
    buffer.removeRange(0, 3 + 1 + payloadLength);
    return new Packet(payloadLength, sequenceId, payload);
  }

  /// Whether this is an OK Packet or not.
  ///
  /// See [MySQL Internals 14.1.3.1](http://dev.mysql.com/doc/internals/en/packet-OK_Packet.html).
  bool get isOK {
    checkState(payload.isNotEmpty, message: 'No packet payload to determine packet status.');
    return payload.first == 0x00 || payload.first == 0xFE;
  }

  /// Whether this is an Err Packet or not.
  ///
  /// See [MySQL Internals 14.1.3.2](http://dev.mysql.com/doc/internals/en/packet-ERR_Packet.html).
  bool get isERR {
    checkState(payload.isNotEmpty, message: 'No packet payload to determine packet status.');
    return payload.first == 0xFF;
  }

  /// Returns a byte buffer corresponding to the [Packet].
  List<int> toBytes() {
    var writer = new BufferWriter();
    writer
      ..writeInt3(length)
      ..writeInt1(sequenceId)
      ..writeBytes(payload);

    return writer.buffer;
  }

  int get hashCode => hashObjects([length, sequenceId, hashObjects(payload)]);

  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! Packet) return false;

    return length == other.length &&
    sequenceId == other.sequenceId &&
    listsEqual(payload, other.payload);
  }

  toString() => 'Packet($sequenceId)[${payload.join(' ')}]';
}
