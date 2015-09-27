import 'dart:convert';

import 'package:dart_mysql/protocol/column_type.dart';
import 'package:dart_mysql/query/column_def.dart';
import 'package:dart_mysql/query/query_handler.dart';
import 'package:dart_mysql/query/result_row.dart';
import 'package:test/test.dart';

main() {
  group('ResultRow', () {
    const schema = 'foo';
    const table = 'bar';
    const col1 = 'a';
    const col2 = 'b';
    const type1 = ColumnType.MYSQL_TYPE_LONGLONG;
    const type2 = ColumnType.MYSQL_TYPE_VAR_STRING;
    const len1 = 20;
    const len2 = 600;
    const charSet = 33;
    const flags = 0x0000;
    const decimals = 0;

    List<dynamic> values;
    ResultRow row;

    setUp(() {
      var def1 = new ColumnDef(schema, table, col1, len1, type1,
          virtualColumnName: '$col1$col1');
      var def2 = new ColumnDef(schema, table, col2, len2, type2,
          virtualColumnName: '$col2$col2');
      var columnDefs = [def1, def2];
      values = [0xdeadbeef, 'foobar'];
      row = new ResultRow(columnDefs, values);
    });

    test('creates copy of list correctly', () {
      expect(row.toList(), orderedEquals(values));
    });

    test('accesses by column name correctly', () {
      expect(row[col1], equals(values[0]));
      expect(row[col2], equals(values[1]));
      expect(row['$col1$col1'], equals(values[0]));
      expect(row['$col2$col2'], equals(values[1]));
    });

    test('accesses by column index correctly', () {
      expect(row[0], equals(values[0]));
      expect(row[1], equals(values[1]));
    });

    test('throws error with invalid column name or index', () {
      expect(() => row[5], throwsArgumentError);
      expect(() => row['$col1$col2'], throwsArgumentError);
    });

    test(
        'throws error when trying to use anything other than int or string to access column',
        () {
      expect(() => row[false], throwsArgumentError);
    });

    test('correctly outputs string', () {
      var result = row.toString();

      expect(result, contains('$col1 = ${values[0].toString()}'));
      expect(result, contains('$col2 = ${values[1].toString()}'));
    });
  });
}
