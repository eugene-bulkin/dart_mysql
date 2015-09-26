import 'package:dart_mysql/query/query_handler.dart';

/// A row in a result set received during a query command.
class ResultRow {
  List<ColumnDef> columnDefs;

  List<dynamic> _row;

  /// Returns a copy of the row list.
  List<dynamic> toList() => _row.toList();

  ResultRow(this.columnDefs, this._row);

  /// Accesses a column via column name or column index.
  String operator [](var key) {
    if (key is String) {
      var def = columnDefs.firstWhere((columnDef) =>
          columnDef.virtualColumnName == key || columnDef.columnName == key);
      return _row[columnDefs.indexOf(def)];
    }
    if (key is int) {
      return _row[key];
    }
    throw new ArgumentError(
        'Can only get column name or column index from ResultRow.');
  }

  toString() {
    var columns = [];
    for (var i = 0; i < columnDefs.length; i++) {
      columns.add('${columnDefs[i].virtualColumnName} = ${_row[i]}');
    }
    return '(${columns.join(', ')})';
  }
}
