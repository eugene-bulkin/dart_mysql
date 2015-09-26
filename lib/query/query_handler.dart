import 'dart:async';
import 'dart:convert';

import 'package:dart_mysql/protocol/packet.dart';
import 'package:dart_mysql/protocol/buffer_reader.dart';
import 'package:logging/logging.dart';
import 'package:dart_mysql/protocol/column_type.dart';
import 'package:quiver/check.dart';
import 'package:dart_mysql/query/result_row.dart';
import 'package:dart_mysql/query/type_parser.dart';

enum QueryStatus { waiting, columnCount, results, }

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

/// A handler that tracks the process of a query command. Handles the sequence of packets defining column definitions
/// and actual results.
///
/// See [MySQL Internals 14.6.4.1](http://dev.mysql.com/doc/internals/en/com-query-response.html).
class QueryHandler {
  final _logger = new Logger('dart_mysql.query.QueryHandler');

  final int _capabilities;

  QueryStatus _queryStatus = QueryStatus.waiting;

  int _columnCount;

  List<ColumnDef> _columnDefs = [];

  List<ResultRow> _rows = [];

  var _completer = new Completer();

  QueryHandler(this._capabilities);

  /// Whether the query is ready or not.
  Future<List<ResultRow>> get done => _completer.future;

  /// Reads a ColumnDefinition41 from a packet.
  ///
  /// See [MySQL Internals 14.6.4.1.1.2](http://dev.mysql.com/doc/internals/en/com-query-response.html#packet-Protocol::ColumnDefinition41).
  void readColumnDefinition(Packet packet) {}

  /// Handles a packet coming as a response during the query.
  void handlePacket(Packet packet) {
    if (packet.payload.first == 0x00) {
      // OK Packet, do nothing.
      return;
    } else if (packet.payload.first == 0xFF) {
      // ERR Packet, so throw error.
      var errPacket = new ERRPacket.fromPacket(packet, _capabilities);
      throw new StateError('Query error: $errPacket');
    }
    var reader = new BufferReader(packet.payload);
    // If the query status is waiting, then we haven't gotten any packet about column count yet.
    if (_queryStatus == QueryStatus.waiting) {
      _columnCount = reader.readLenencInt();
      _logger.finest('Received first query packet. Num Columns: $_columnCount');
      _queryStatus = QueryStatus.columnCount;
      return;
    }
    // Column count has been received, so read in column definitions.
    if (_queryStatus == QueryStatus.columnCount) {
      // If the OK packet is received, column definitions are done coming in.
      if (packet.isOK) {
        checkState(_columnDefs.length == _columnCount,
            message: 'Incorrect number of columns');
        _queryStatus = QueryStatus.results;
        return;
      }
      _columnDefs.add(new ColumnDef.fromPacket(packet));
      return;
    }
    // Otherwise, we are receiving rows.
    // If the OK Packet is received, done receiving rows.
    if (packet.isOK) {
      _completer.complete(_rows);
      return;
    }
    var row = [];
    for (var i = 0; i < _columnCount; i++) {
      var bytes = reader.readLenencString();
      // Parse values into proper types.
      var value = TypeParser.parseText(_columnDefs[i].columnType, bytes);
      row.add(value);
    }
    _rows.add(new ResultRow(_columnDefs, row));
  }
}
