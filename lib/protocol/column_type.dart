const _typeNames = const {
  0x00: 'DECIMAL',
  0x01: 'TINY',
  0x02: 'SHORT',
  0x03: 'LONG',
  0x04: 'FLOAT',
  0x05: 'DOUBLE',
  0x06: 'NULL',
  0x07: 'TIMESTAMP',
  0x08: 'LONGLONG',
  0x09: 'INT24',
  0x0a: 'DATE',
  0x0b: 'TIME',
  0x0c: 'DATETIME',
  0x0d: 'YEAR',
  0x0e: 'NEWDATE',
  0x0f: 'VARCHAR',
  0x10: 'BIT',
  0x11: 'TIMESTAMP2',
  0x12: 'DATETIME2',
  0x13: 'TIME2',
  0xf6: 'NEWDECIMAL',
  0xf7: 'ENUM',
  0xf8: 'SET',
  0xf9: 'TINY_BLOB',
  0xfa: 'MEDIUM_BLOB',
  0xfb: 'LONG_BLOB',
  0xfc: 'BLOB',
  0xfd: 'VAR_STRING',
  0xfe: 'STRING',
  0xff: 'GEOMETRY',
};

/// The type of a given column. Some types are only used internally to the MySQL server.
class ColumnType {
  static const MYSQL_TYPE_DECIMAL = const ColumnType(0x00);
  static const MYSQL_TYPE_TINY = const ColumnType(0x01);
  static const MYSQL_TYPE_SHORT = const ColumnType(0x02);
  static const MYSQL_TYPE_LONG = const ColumnType(0x03);
  static const MYSQL_TYPE_FLOAT = const ColumnType(0x04);
  static const MYSQL_TYPE_DOUBLE = const ColumnType(0x05);
  static const MYSQL_TYPE_NULL = const ColumnType(0x06);
  static const MYSQL_TYPE_TIMESTAMP = const ColumnType(0x07);
  static const MYSQL_TYPE_LONGLONG = const ColumnType(0x08);
  static const MYSQL_TYPE_INT24 = const ColumnType(0x09);
  static const MYSQL_TYPE_DATE = const ColumnType(0x0a);
  static const MYSQL_TYPE_TIME = const ColumnType(0x0b);
  static const MYSQL_TYPE_DATETIME = const ColumnType(0x0c);
  static const MYSQL_TYPE_YEAR = const ColumnType(0x0d);
  static const MYSQL_TYPE_NEWDATE = const ColumnType(0x0e);
  static const MYSQL_TYPE_VARCHAR = const ColumnType(0x0f);
  static const MYSQL_TYPE_BIT = const ColumnType(0x10);
  static const MYSQL_TYPE_TIMESTAMP2 = const ColumnType(0x11);
  static const MYSQL_TYPE_DATETIME2 = const ColumnType(0x12);
  static const MYSQL_TYPE_TIME2 = const ColumnType(0x13);
  static const MYSQL_TYPE_NEWDECIMAL = const ColumnType(0xf6);
  static const MYSQL_TYPE_ENUM = const ColumnType(0xf7);
  static const MYSQL_TYPE_SET = const ColumnType(0xf8);
  static const MYSQL_TYPE_TINY_BLOB = const ColumnType(0xf9);
  static const MYSQL_TYPE_MEDIUM_BLOB = const ColumnType(0xfa);
  static const MYSQL_TYPE_LONG_BLOB = const ColumnType(0xfb);
  static const MYSQL_TYPE_BLOB = const ColumnType(0xfc);
  static const MYSQL_TYPE_VAR_STRING = const ColumnType(0xfd);
  static const MYSQL_TYPE_STRING = const ColumnType(0xfe);
  static const MYSQL_TYPE_GEOMETRY = const ColumnType(0xff);

  final int value;

  const ColumnType(this.value);

  toString() => 'ColumnType.${_typeNames[value]}';

  int get hashCode => value.hashCode;

  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! ColumnType) return false;

    return value == other.value;
  }
}
