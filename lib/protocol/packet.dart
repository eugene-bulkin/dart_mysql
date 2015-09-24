library dart_mysql.protocol.packet;

import 'package:dart_mysql/protocol/buffer_reader.dart';
import 'package:dart_mysql/protocol/buffer_writer.dart';

/// A MySQL client/server protocol packet.
class Packet {
  /// The length of the packet.
  final int length;

  /// The sequence ID of the packet.
  final int sequenceId;

  /// The byte-array corresponding to the payload.
  final List<int> payload;

  Packet(this.length, this.sequenceId, this.payload);

  /// Creates a new packet from a buffer. Modifies the buffer by removing the packet itself (so one can run
  /// [new Packet.fromBuffer] multiple times to get all packets).
  ///
  /// See [MySQL Internals 14.1.2](http://dev.mysql.com/doc/internals/en/mysql-packet.html) for details.
  factory Packet.fromBuffer(List<int> buffer) {
    var reader = new BufferReader(buffer);
    var payloadLength = reader.readInt3();
    var sequenceId = reader.readInt1();
    var payload = reader.readBytes(payloadLength);
    buffer.removeRange(0, 3 + 1 + payloadLength);
    return new Packet(payloadLength, sequenceId, payload);
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
}
