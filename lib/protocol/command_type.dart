library dart_mysql.protocol.commmand_type;

/// Flags describing command types.
///
/// See [MySQL Internals Manual 14.1.6](http://dev.mysql.com/doc/internals/en/command-phase.html).
class CommandType {
  static const COM_SLEEP = 0x00;
  static const COM_QUIT = 0x01;
  static const COM_INIT_DB = 0x02;
  static const COM_QUERY = 0x03;
  static const COM_FIELD_LIST = 0x04;
  static const COM_CREATE_DB = 0x05;
  static const COM_DROP_DB = 0x06;
  static const COM_REFRESH = 0x07;
  static const COM_SHUTDOWN = 0x08;
  static const COM_STATISTICS = 0x09;
  static const COM_PROCESS_INFO = 0x0a;
  static const COM_CONNECT = 0x0b;
  static const COM_PROCESS_KILL = 0x0c;
  static const COM_DEBUG = 0x0d;
  static const COM_PING = 0x0e;
  static const COM_TIME = 0x0f;
  static const COM_DELAYED_INSERT = 0x10;
  static const COM_CHANGE_USER = 0x11;
  static const COM_BINLOG_DUMP = 0x12;
  static const COM_TABLE_DUMP = 0x13;
  static const COM_CONNECT_OUT = 0x14;
  static const COM_REGISTER_SLAVE = 0x15;
  static const COM_STMT_PREPARE = 0x16;
  static const COM_STMT_EXECUTE = 0x17;
  static const COM_STMT_SEND_LONG_DATA = 0x18;
  static const COM_STMT_CLOSE = 0x19;
  static const COM_STMT_RESET = 0x1a;
  static const COM_SET_OPTION = 0x1b;
  static const COM_STMT_FETCH = 0x1c;
  static const COM_DAEMON = 0x1d;
  static const COM_BINLOG_DUMP_GTID = 0x1e;
  static const COM_RESET_CONNECTION = 0x1f;
}
