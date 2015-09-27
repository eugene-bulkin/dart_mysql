import 'package:dart_mysql/protocol/column_type.dart';
import 'package:quiver/testing/equality.dart';
import 'package:test/test.dart';

main() {
  group('ColumnType', () {
    test('outputs correct string', () {
      expect(ColumnType.MYSQL_TYPE_DECIMAL.toString(),
          equals('ColumnType.DECIMAL'));
      expect(ColumnType.MYSQL_TYPE_TINY.toString(), equals('ColumnType.TINY'));
      expect(
          ColumnType.MYSQL_TYPE_SHORT.toString(), equals('ColumnType.SHORT'));
      expect(ColumnType.MYSQL_TYPE_LONG.toString(), equals('ColumnType.LONG'));
      expect(
          ColumnType.MYSQL_TYPE_FLOAT.toString(), equals('ColumnType.FLOAT'));
      expect(
          ColumnType.MYSQL_TYPE_DOUBLE.toString(), equals('ColumnType.DOUBLE'));
      expect(ColumnType.MYSQL_TYPE_NULL.toString(), equals('ColumnType.NULL'));
      expect(ColumnType.MYSQL_TYPE_TIMESTAMP.toString(),
          equals('ColumnType.TIMESTAMP'));
      expect(ColumnType.MYSQL_TYPE_LONGLONG.toString(),
          equals('ColumnType.LONGLONG'));
      expect(
          ColumnType.MYSQL_TYPE_INT24.toString(), equals('ColumnType.INT24'));
      expect(ColumnType.MYSQL_TYPE_DATE.toString(), equals('ColumnType.DATE'));
      expect(ColumnType.MYSQL_TYPE_TIME.toString(), equals('ColumnType.TIME'));
      expect(ColumnType.MYSQL_TYPE_DATETIME.toString(),
          equals('ColumnType.DATETIME'));
      expect(ColumnType.MYSQL_TYPE_YEAR.toString(), equals('ColumnType.YEAR'));
      expect(ColumnType.MYSQL_TYPE_NEWDATE.toString(),
          equals('ColumnType.NEWDATE'));
      expect(ColumnType.MYSQL_TYPE_VARCHAR.toString(),
          equals('ColumnType.VARCHAR'));
      expect(ColumnType.MYSQL_TYPE_BIT.toString(), equals('ColumnType.BIT'));
      expect(ColumnType.MYSQL_TYPE_TIMESTAMP2.toString(),
          equals('ColumnType.TIMESTAMP2'));
      expect(ColumnType.MYSQL_TYPE_DATETIME2.toString(),
          equals('ColumnType.DATETIME2'));
      expect(
          ColumnType.MYSQL_TYPE_TIME2.toString(), equals('ColumnType.TIME2'));
      expect(ColumnType.MYSQL_TYPE_NEWDECIMAL.toString(),
          equals('ColumnType.NEWDECIMAL'));
      expect(ColumnType.MYSQL_TYPE_ENUM.toString(), equals('ColumnType.ENUM'));
      expect(ColumnType.MYSQL_TYPE_SET.toString(), equals('ColumnType.SET'));
      expect(ColumnType.MYSQL_TYPE_TINY_BLOB.toString(),
          equals('ColumnType.TINY_BLOB'));
      expect(ColumnType.MYSQL_TYPE_MEDIUM_BLOB.toString(),
          equals('ColumnType.MEDIUM_BLOB'));
      expect(ColumnType.MYSQL_TYPE_LONG_BLOB.toString(),
          equals('ColumnType.LONG_BLOB'));
      expect(ColumnType.MYSQL_TYPE_BLOB.toString(), equals('ColumnType.BLOB'));
      expect(ColumnType.MYSQL_TYPE_VAR_STRING.toString(),
          equals('ColumnType.VAR_STRING'));
      expect(
          ColumnType.MYSQL_TYPE_STRING.toString(), equals('ColumnType.STRING'));
      expect(ColumnType.MYSQL_TYPE_GEOMETRY.toString(),
          equals('ColumnType.GEOMETRY'));
    });

    test('equality and hashCode', () {
      expect({
        'DECIMAL': [ColumnType.MYSQL_TYPE_DECIMAL],
        'TINY': [ColumnType.MYSQL_TYPE_TINY],
        'SHORT': [ColumnType.MYSQL_TYPE_SHORT],
        'LONG': [ColumnType.MYSQL_TYPE_LONG],
        'FLOAT': [ColumnType.MYSQL_TYPE_FLOAT],
        'DOUBLE': [ColumnType.MYSQL_TYPE_DOUBLE],
        'NULL': [ColumnType.MYSQL_TYPE_NULL],
        'TIMESTAMP': [ColumnType.MYSQL_TYPE_TIMESTAMP],
        'LONGLONG': [ColumnType.MYSQL_TYPE_LONGLONG],
        'INT24': [ColumnType.MYSQL_TYPE_INT24],
        'DATE': [ColumnType.MYSQL_TYPE_DATE],
        'TIME': [ColumnType.MYSQL_TYPE_TIME],
        'DATETIME': [ColumnType.MYSQL_TYPE_DATETIME],
        'YEAR': [ColumnType.MYSQL_TYPE_YEAR],
        'NEWDATE': [ColumnType.MYSQL_TYPE_NEWDATE],
        'VARCHAR': [ColumnType.MYSQL_TYPE_VARCHAR],
        'BIT': [ColumnType.MYSQL_TYPE_BIT],
        'TIMESTAMP2': [ColumnType.MYSQL_TYPE_TIMESTAMP2],
        'DATETIME2': [ColumnType.MYSQL_TYPE_DATETIME2],
        'TIME2': [ColumnType.MYSQL_TYPE_TIME2],
        'NEWDECIMAL': [ColumnType.MYSQL_TYPE_NEWDECIMAL],
        'ENUM': [ColumnType.MYSQL_TYPE_ENUM],
        'SET': [ColumnType.MYSQL_TYPE_SET],
        'TINY_BLOB': [ColumnType.MYSQL_TYPE_TINY_BLOB],
        'MEDIUM_BLOB': [ColumnType.MYSQL_TYPE_MEDIUM_BLOB],
        'LONG_BLOB': [ColumnType.MYSQL_TYPE_LONG_BLOB],
        'BLOB': [ColumnType.MYSQL_TYPE_BLOB],
        'VAR_STRING': [ColumnType.MYSQL_TYPE_VAR_STRING],
        'STRING': [ColumnType.MYSQL_TYPE_STRING],
        'GEOMETRY': [ColumnType.MYSQL_TYPE_GEOMETRY],
      }, areEqualityGroups);
    });
  });
}
