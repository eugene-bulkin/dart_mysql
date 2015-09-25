library dart_mysql.protocol.connection;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:dart_mysql/protocol/buffer_reader.dart';
import 'package:dart_mysql/protocol/buffer_writer.dart';
import 'package:dart_mysql/protocol/capability_flags.dart';
import 'package:dart_mysql/protocol/command_type.dart';
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

  int _serverCapabilities;

  int _clientCapabilities;

  StreamSubscription _packetSubscription;

  /// Hashes the password provided with the auth scramble to create the authentication hash.
  ///
  /// See [MySQL Internals 14.3.3](http://dev.mysql.com/doc/internals/en/secure-password-authentication.html).
  static List<int> hashPassword(String password, List<int> scramble) {
    if (password == null) {
      return [];
    }
    var hasher = new SHA1();
    hasher.add(UTF8.encode(password));
    var hashedPassword = hasher.close();

    hasher = new SHA1()
      ..add(hashedPassword);
    var doubleHashedPassword = hasher.close();

    hasher = new SHA1();
    hasher.add(scramble);
    hasher.add(doubleHashedPassword);
    var scrambleHash = hasher.close();

    var hash = new List<int>(hashedPassword.length);
    for (var i = 0; i < hashedPassword.length; i++) {
      hash[i] = hashedPassword[i] ^ scrambleHash[i];
    }

    return hash;
  }

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

    _logger.finest('Auth plugin: $authPluginName. Auth data: $authPluginData.');

    return new HandshakeData(serverVersion, connectionId, capabilities,
    characterSet, statusFlags, authPluginData, authPluginName);
  }

  /// Processes handshake data and returns the proper Handshake Response packet.
  Packet makeResponse(HandshakeData handshake) {
    _serverCapabilities = handshake.capabilities;
    if (_serverCapabilities & CapabilityFlags.CLIENT_PROTOCOL_41 == 0) {
      throw new UnsupportedError('Client versions below 4.1 not supported.');
    }

    _clientCapabilities = CapabilityFlags.CLIENT_PROTOCOL_41 |
    CapabilityFlags.CLIENT_LONG_PASSWORD |
    CapabilityFlags.CLIENT_LONG_FLAG |
    CapabilityFlags.CLIENT_TRANSACTIONS |
    CapabilityFlags.CLIENT_SECURE_CONNECTION;
    if (database != null) {
      _clientCapabilities |= CapabilityFlags.CLIENT_CONNECT_WITH_DB;
    }

    var writer = new BufferWriter();
    writer.writeInt4(_clientCapabilities);
    writer.writeInt4(0x01000000);
    writer.writeInt1(handshake.characterSet);
    writer.fill(23);
    writer.writeNullTerminatedString(username);

    if (_serverCapabilities & CapabilityFlags.CLIENT_SECURE_CONNECTION > 0) {
      var hash = hashPassword(password, handshake.authPluginData);
      writer.writeInt1(hash.length);
      writer.writeBytes(hash);
    }

    if (database != null) {
      writer.writeNullTerminatedString(database);
    }

    if (_serverCapabilities & CapabilityFlags.CLIENT_PLUGIN_AUTH > 0) {
      writer.writeNullTerminatedString(handshake.authPluginName);
    }

    return new Packet(writer.buffer.length, 1, writer.buffer);
  }

  /// Performs the MySQL client/server handshake.
  ///
  /// First this parses the [Initial Handshake Packet](http://dev.mysql.com/doc/internals/en/connection-phase-packets.html#packet-Protocol::Handshake),
  /// assuming Protocol Version V10.
  ///
  /// Then the [Handshake Response](http://dev.mysql.com/doc/internals/en/connection-phase-packets.html#packet-Protocol::HandshakeResponse)
  /// is created and sent back to the server.
  void doHandshake(Packet packet) {
    _logger.finest('Received initial handshake packet.');
    var handshakeData = parseHandshake(packet.payload);
    _logger.finest('Parsed handshake. Creating response.');
    var responsePacket = makeResponse(handshakeData);

    _bus.sendPacket(responsePacket);
  }

  factory Connection(String host, int port, String username,
                     {String password, String database}) {
    var bus = new ServerBus(host, port);

    var connection = new Connection.fromBus(bus, username,
    password: password, database: database);

    return connection;
  }

  Connection.fromBus(this._bus, this.username, {this.password, this.database}) {
    checkNotNull(_bus);
    checkNotNull(username);
  }

  /// Connects to the server and completes the client/server handshake.
  Future connect() async {
    var handshakePacketFuture = _bus.stream.first;
    var responsePacketFuture = _bus.stream.first;

    await _bus.connected;

    doHandshake(await handshakePacketFuture);

    var handshakeResponsePacket = await responsePacketFuture;
    if (!handshakeResponsePacket.isOK) {
      // TODO(eugene-bulkin): Print actual MySQL error message from ERR_Packet here.
      throw new StateError('Unable to complete handshake.');
    }
    _packetSubscription = _bus.stream.listen(onPacket, onDone: close);
    return new Future.value(true);
  }

  Future quit() async {
    _bus.sendPacket(new Packet(1, 0, [CommandType.COM_QUIT]));
  }

  Future close() async {
    _logger.finest('Closing Connection.');
    await quit();
    if (_packetSubscription != null) {
      await _packetSubscription.cancel();
      _packetSubscription = null;
    }
  }

  /// Handles packets coming in from the [ServerBus].
  void onPacket(Packet packet) {
    // TODO(eugene-bulkin): Handle all packets here.
  }
}
