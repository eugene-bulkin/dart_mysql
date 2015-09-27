library dart_mysql.query.column_def;

import 'dart:convert';

import 'package:dart_mysql/protocol/buffer_reader.dart';
import 'package:dart_mysql/protocol/column_type.dart';
import 'package:dart_mysql/protocol/packet.dart';

/// A definition of a MySQL column; stores both virtual (i.e. aliased) names and actual names.
class ColumnDef {
  final String schema;

  final String virtualTableName;

  final String tableName;

  final String virtualColumnName;

  final String columnName;

  final int characterSet;

  final int columnLength;

  final ColumnType columnType;

  final int flags;

  final int decimals;

  factory ColumnDef.fromPacket(Packet packet) {
    var reader = new BufferReader(packet.payload);

    reader.readLenencString(); // catalog, always "def"

    var schema = UTF8.decode(reader.readLenencString());
    var virtualTableName = UTF8.decode(reader.readLenencString());
    var tableName = UTF8.decode(reader.readLenencString());
    var virtualColumnName = UTF8.decode(reader.readLenencString());
    var columnName = UTF8.decode(reader.readLenencString());

    reader.readLenencInt(); // next_length, always 0x0c

    var characterSet = reader.readInt2();
    var columnLength = reader.readInt4();
    var columnType = new ColumnType(reader.readInt1());
    var flags = reader.readInt2();
    var decimals = reader.readInt1();

    return new ColumnDef._(
        schema,
        virtualTableName,
        tableName,
        columnName,
        virtualColumnName,
        characterSet,
        columnLength,
        columnType,
        flags,
        decimals);
  }

  ColumnDef._(
      this.schema,
      this.virtualTableName,
      this.tableName,
      this.columnName,
      this.virtualColumnName,
      this.characterSet,
      this.columnLength,
      this.columnType,
      this.flags,
      this.decimals);
}
