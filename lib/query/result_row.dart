import 'package:dart_mysql/query/column_def.dart';

/// A row in a result set received during a query command.
class ResultRow {
  List<ColumnDef> columnDefs;

  List<dynamic> _row;

  /// Returns a copy of the row list.
  List<dynamic> toList() => _row.toList();

  ResultRow(this.columnDefs, this._row);

  /// Accesses a column via column name or column index.
  dynamic operator [](var key) {
    if (key is String) {
      ColumnDef def;
      try {
        def = columnDefs.firstWhere((columnDef) =>
            columnDef.virtualColumnName == key || columnDef.columnName == key);
      } on StateError catch (_) {
        throw new ArgumentError('Column by name "$key" does not exist.');
      }
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
