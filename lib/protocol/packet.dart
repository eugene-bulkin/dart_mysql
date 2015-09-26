library dart_mysql.protocol.packet;

import 'dart:convert';

import 'package:dart_mysql/protocol/buffer_reader.dart';
import 'package:dart_mysql/protocol/buffer_writer.dart';
import 'package:dart_mysql/protocol/capability_flags.dart';
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
    checkState(payload.isNotEmpty,
        message: 'No packet payload to determine packet status.');
    return payload.first == 0x00 || payload.first == 0xFE;
  }

  /// Whether this is an Err Packet or not.
  ///
  /// See [MySQL Internals 14.1.3.2](http://dev.mysql.com/doc/internals/en/packet-ERR_Packet.html).
  bool get isERR {
    checkState(payload.isNotEmpty,
        message: 'No packet payload to determine packet status.');
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

class OKPacket extends Packet {
  int affectedRows;
  int lastInsertId;
  int statusFlags;
  int numWarnings = 0;
  String info;

  OKPacket.fromPacket(Packet packet, int capabilities)
      : super(packet.length, packet.sequenceId, packet.payload) {
    checkArgument(packet.isOK,
        message: 'Cannot create OKPacket from a non-OK Packet');

    var reader = new BufferReader(packet.payload.sublist(1));

    affectedRows = reader.readLenencInt();
    lastInsertId = reader.readLenencInt();
    if (capabilities & CapabilityFlags.CLIENT_PROTOCOL_41 > 0) {
      statusFlags = reader.readInt2();
      numWarnings = reader.readInt2();
    }
    info = UTF8.decode(reader.readEOFString());
  }
}

class ERRPacket extends Packet {
  int errorCode;
  String sqlStateMarker;
  String sqlState;
  String errorMessage;

  ERRPacket.fromPacket(Packet packet, int capabilities)
      : super(packet.length, packet.sequenceId, packet.payload) {
    checkArgument(packet.isERR,
        message: 'Cannot create ERRPacket from a non-ERR Packet');
    var reader = new BufferReader(packet.payload.sublist(1));

    errorCode = reader.readInt2();
    sqlStateMarker = UTF8.decode(reader.readBytes(1));
    sqlState = UTF8.decode(reader.readBytes(5));
    errorMessage = UTF8.decode(reader.readEOFString());
  }

  toString() => '#$errorCode ($sqlStateMarker$sqlState): $errorMessage';
}
