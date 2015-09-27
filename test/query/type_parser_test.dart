import 'dart:convert';

import 'package:dart_mysql/protocol/column_type.dart';
import 'package:dart_mysql/query/type_parser.dart';
import 'package:test/test.dart';

main() {
  group('TypeParser', () {
    test('parses strings correctly', () {
      const value = 'foo';
      var buffer = UTF8.encode(value);

      expect(TypeParser.parseText(ColumnType.MYSQL_TYPE_VAR_STRING, buffer),
      equals(value));
    });

    test('parses ints correctly', () {
      var value = 5;
      var buffer = UTF8.encode(value.toString());

      expect(TypeParser.parseText(ColumnType.MYSQL_TYPE_TINY, buffer) as int,
      equals(value));
      expect(TypeParser.parseText(ColumnType.MYSQL_TYPE_SHORT, buffer) as int,
      equals(value));
      expect(TypeParser.parseText(ColumnType.MYSQL_TYPE_LONG, buffer) as int,
      equals(value));
      expect(
          TypeParser.parseText(ColumnType.MYSQL_TYPE_LONGLONG, buffer) as int,
          equals(value));
    });

    test('parses doubles/floats correctly', () {
      var value = 3.7;
      var buffer = UTF8.encode(value.toString());

      expect(
          TypeParser.parseText(ColumnType.MYSQL_TYPE_DOUBLE, buffer) as double,
          equals(value));
      expect(
          TypeParser.parseText(ColumnType.MYSQL_TYPE_FLOAT, buffer) as double,
          equals(value));
    });
  });
}
