library dart_mysql.protocol.connection;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dart_mysql/protocol/buffer_reader.dart';
import 'package:dart_mysql/protocol/capability_flags.dart';
import 'package:dart_mysql/protocol/packet.dart';
import 'package:dart_mysql/protocol/server_bus.dart';
import 'package:logging/logging.dart';
import 'package:quiver/check.dart';

/// A container for initial handshake packet data.
class HandshakeData {
  final String serverVersion;
  final int connectionId;
  final List<int> authPluginData;
  final int capabilities;
  final int statusFlags;
  final int characterSet;
  final String authPluginName;

  HandshakeData(
      this.serverVersion,
      this.connectionId,
      this.capabilities,
      this.characterSet,
      this.statusFlags,
      this.authPluginData,
      this.authPluginName);
}

/// A connection to a MySQL server.
///
/// This partially looks at packets in order to determine which type of packet they are.
class Connection {
  final _logger = new Logger('dart_mysql.protocol.Connection');

  final ServerBus _bus;

  final String username;

  final String password;

  final String database;

  StreamSubscription _packetSubscription;

  /// Takes in the initial handshake packet buffer and parses it into the relevant data.
  HandshakeData parseHandshake(List<int> buffer) {
    var reader = new BufferReader(buffer);

    var protocolVersion = reader.readInt1();
    if (protocolVersion != 10) {
      throw new UnsupportedError(
          'Handshake Protocol Version other than 10 not supported.');
    }

    var serverVersion = UTF8.decode(reader.readNullTerminatedString());
    var connectionId = reader.readInt4();

    _logger.fine(
        'Connecting to MySQL Version $serverVersion. Connection ID: $connectionId');

    // The data is mutable here because we may get more later.
    var authPluginData = reader.readBytes(8).toList(growable: true);

    reader.readInt1(); // filler

    var capabilityFlag1 = reader.readInt2(); // lower two bytes
    var characterSet = reader.readInt1();
    var statusFlags = reader.readInt2();
    var capabilityFlag2 = reader.readInt2(); // upper two bytes

    var capabilities = capabilityFlag1 + (capabilityFlag2 << 16);

    _logger.finest(
        'Character set: $characterSet, Capabilities: 0x${capabilities.toRadixString(16)}, Status Flags: 0x${statusFlags.toRadixString(16)}.');

    int authPluginDataLen;
    if (capabilities & CapabilityFlags.CLIENT_PLUGIN_AUTH > 0) {
      authPluginDataLen = reader.readInt1();
    } else {
      reader.readInt1();
      authPluginDataLen = 0;
    }

    reader.readBytes(10); // reserved 10 NUL byte filler

    if (capabilities & CapabilityFlags.CLIENT_SECURE_CONNECTION > 0) {
      var len = math.max(13, authPluginDataLen - 8);
      authPluginData.addAll(reader.readBytes(len));
      if (authPluginData.last == 0) {
        authPluginData.removeLast();
      }
    }
    String authPluginName;
    if (capabilities & CapabilityFlags.CLIENT_PLUGIN_AUTH > 0) {
      authPluginName = UTF8.decode(reader.readNullTerminatedString());
    }

    _logger.finest(
        'Handshake parsed. Auth plugin: $authPluginName. Auth data: $authPluginData.');

    return new HandshakeData(serverVersion, connectionId, capabilities,
    characterSet, statusFlags, authPluginData, authPluginName);
  }

  /// Performs the MySQL client/server handshake.
  ///
  /// First this parses the [Initial Handshake Packet](http://dev.mysql.com/doc/internals/en/connection-phase-packets.html#packet-Protocol::Handshake),
  /// assuming Protocol Version V10.
  ///
  /// Then the [Handshake Response](http://dev.mysql.com/doc/internals/en/connection-phase-packets.html#packet-Protocol::HandshakeResponse)
  /// is created and sent back to the server.
  Future doHandshake(Packet packet) async {
    _logger.finest('Received initial handshake packet.');
    var handshakeData = parseHandshake(packet.payload);
    // TODO(eugene-bulkin): Generate handshake response.

    return new Future.value(null);
  }

  Connection(this._bus, this.username, {this.password, this.database}) {
    checkNotNull(_bus);
    checkNotNull(username);
  }

  /// Connects to the server and completes the client/server handshake.
  Future connect() async {
    await _bus.connected;
    await doHandshake(await _bus.stream.first);
    _packetSubscription = _bus.stream.listen(onPacket);
  }

  /// Handles packets coming in from the [ServerBus].
  void onPacket(Packet packet) {
    // TODO(eugene-bulkin): Handle all packets here.
  }
}
