library dart_mysql.protocol.capability_flags;

/// Flags denoting server and/or client capabilities.
///
/// See [MySQL Internals Manual 14.2.6](http://dev.mysql.com/doc/internals/en/capability-flags.html#packet-Protocol::CapabilityFlags).
class CapabilityFlags {
  static const CLIENT_LONG_PASSWORD = 0x00000001;
  static const CLIENT_FOUND_ROWS = 0x00000002;
  static const CLIENT_LONG_FLAG = 0x00000004;
  static const CLIENT_CONNECT_WITH_DB = 0x00000008;
  static const CLIENT_NO_SCHEMA = 0x00000010;
  static const CLIENT_COMPRESS = 0x00000020;
  static const CLIENT_ODBC = 0x00000040;
  static const CLIENT_LOCAL_FILES = 0x00000080;
  static const CLIENT_IGNORE_SPACE = 0x00000100;
  static const CLIENT_PROTOCOL_41 = 0x00000200;
  static const CLIENT_INTERACTIVE = 0x00000400;
  static const CLIENT_SSL = 0x00000800;
  static const CLIENT_IGNORE_SIGPIPE = 0x00001000;
  static const CLIENT_TRANSACTIONS = 0x00002000;
  static const CLIENT_RESERVED = 0x00004000;
  static const CLIENT_SECURE_CONNECTION = 0x00008000;
  static const CLIENT_MULTI_STATEMENTS = 0x00010000;
  static const CLIENT_MULTI_RESULTS = 0x00020000;
  static const CLIENT_PS_MULTI_RESULTS = 0x00040000;
  static const CLIENT_PLUGIN_AUTH = 0x00080000;
  static const CLIENT_CONNECT_ATTRS = 0x00100000;
  static const CLIENT_PLUGIN_AUTH_LENENC_CLIENT_DATA = 0x00200000;
  static const CLIENT_CAN_HANDLE_EXPIRED_PASSWORDS = 0x00400000;
  static const CLIENT_SESSION_TRACK = 0x00800000;
  static const CLIENT_DEPRECATE_EOF = 0x01000000;
}
