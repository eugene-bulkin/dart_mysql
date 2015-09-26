library dart_mysql.query.type_parser;

import 'dart:convert';

import 'package:dart_mysql/protocol/buffer_reader.dart';
import 'package:dart_mysql/protocol/column_type.dart';

/// Parses a byte buffer into either a String or a numeric type depending on the [ColumnType].
class TypeParser {
  /// Parses a ProtocolText value. These are always sent in as strings, but they may be numeric values.
  static dynamic parseText(ColumnType type, List<int> bytes) {
    var reader = new BufferReader(bytes);
    var value = UTF8.decode(reader.readEOFString());
    if (type == ColumnType.MYSQL_TYPE_LONGLONG ||
        type == ColumnType.MYSQL_TYPE_LONG ||
        type == ColumnType.MYSQL_TYPE_SHORT ||
        type == ColumnType.MYSQL_TYPE_TINY) {
      return int.parse(value);
    }

    if (type == ColumnType.MYSQL_TYPE_DOUBLE ||
        type == ColumnType.MYSQL_TYPE_FLOAT) {
      return double.parse(value);
    }

    return value;
  }
}
