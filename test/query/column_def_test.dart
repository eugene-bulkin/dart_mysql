import 'package:dart_mysql/protocol/buffer_writer.dart';
import 'package:dart_mysql/protocol/column_type.dart';
import 'package:dart_mysql/protocol/packet.dart';
import 'package:dart_mysql/query/column_def.dart';
import 'package:dart_mysql/testing/utils.dart';
import 'package:test/test.dart';

main() {
  group('ColumnDef', () {
    // We would expect this from: SELECT cookie AS c FROM foo.bar as baz;
    const schema = 'foo';
    const virtualTable = 'baz';
    const table = 'bar';
    const virtualColumnName = 'c';
    const columnName = 'cookie';
    const characterSet = 33;
    const columnLength = 600;
    const flags = 0x0000;
    const decimals = 0;
    const columnType = ColumnType.MYSQL_TYPE_VAR_STRING;

    Packet packet;

    setUp(() {
      packet = createColumnDefPacket(
          schema, table, columnName, columnLength, columnType,
          virtualColumnName: virtualColumnName,
          virtualTableName: virtualTable,
          characterSet: characterSet,
          flags: flags,
          decimals: decimals);
    });

    test('correctly creates ColumnDef', () {
      var columnDef = new ColumnDef.fromPacket(packet);

      expect(columnDef.schema, equals(schema));
      expect(columnDef.virtualTableName, equals(virtualTable));
      expect(columnDef.tableName, equals(table));
      expect(columnDef.virtualColumnName, equals(virtualColumnName));
      expect(columnDef.columnName, equals(columnName));
      expect(columnDef.characterSet, equals(characterSet));
      expect(columnDef.columnLength, equals(columnLength));
      expect(columnDef.flags, equals(flags));
      expect(columnDef.decimals, equals(decimals));
      expect(columnDef.columnType, equals(columnType));
    });
  });
}
