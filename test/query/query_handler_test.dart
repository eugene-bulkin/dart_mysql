import 'dart:convert';

import 'package:dart_mysql/protocol/capability_flags.dart';
import 'package:dart_mysql/protocol/column_type.dart';
import 'package:dart_mysql/protocol/packet.dart';
import 'package:dart_mysql/query/query_handler.dart';
import 'package:dart_mysql/query/result_row.dart';
import 'package:dart_mysql/testing/utils.dart';
import 'package:test/test.dart';

main() {
  group('QueryHandler', () {
    final columnDefPacket = createColumnDefPacket(
        'foo', 'bar', 'baz', 20, ColumnType.MYSQL_TYPE_LONGLONG);
    QueryHandler handler;

    setUp(() {
      handler = new QueryHandler(CapabilityFlags.CLIENT_PROTOCOL_41);
    });

    test('does nothing on OK Packet', () {
      handler.handlePacket(new Packet(1, 0, [0x00]));
      expect(handler.status, equals(QueryStatus.waiting));
    });

    test('throws state error on ERR Packet', () {
      expect(
          () => handler.handlePacket(new Packet(1, 0, [
                0xFF,
                0x88,
                0x13,
                0x23,
                0x66,
                0x6F,
                0x6F,
                0x00,
                0x00,
                0x62,
                0x61,
                0x72,
                0x20,
                0x62,
                0x61,
                0x7A
              ])),
          throwsStateError);
    });

    test('moves to column count stage after column count arrives', () {
      handler.handlePacket(new Packet(1, 0, [5]));
      expect(handler.status, equals(QueryStatus.columnCount));
    });

    group('throws error if mismatch in # of column defs', () {
      setUp(() {
        handler.handlePacket(new Packet(1, 0, [2]));
      });

      test('with too few columns', () {
        handler.handlePacket(columnDefPacket);
        expect(() => handler.handlePacket(new Packet(1, 0, [0xFE])),
            throwsStateError);
      });

      test('with too many columns', () {
        handler.handlePacket(columnDefPacket);
        handler.handlePacket(columnDefPacket);
        handler.handlePacket(columnDefPacket);
        expect(() => handler.handlePacket(new Packet(1, 0, [0xFE])),
            throwsStateError);
      });
    });

    test('proceeds to results after column defs', () {
      handler.handlePacket(new Packet(1, 0, [2]));
      handler.handlePacket(columnDefPacket);
      handler.handlePacket(columnDefPacket);
      handler.handlePacket(new Packet(1, 0, [0xFE]));
      expect(handler.status, equals(QueryStatus.results));
    });

    test('completes with correct rows', () async {
      const value1 = 0x1234567812345678;
      const value2 = 0x8765432187654321;

      // Column defs
      handler.handlePacket(new Packet(1, 0, [1]));
      handler.handlePacket(columnDefPacket);
      handler.handlePacket(new Packet(1, 0, [0xFE]));

      handler.handlePacket(createResultRowPacket([value1.toString()]));
      handler.handlePacket(createResultRowPacket([value2.toString()]));
      handler.handlePacket(new Packet(1, 0, [0xFE]));
      var result = await handler.done;

      expect(result, hasLength(2));

      var row1 = result[0];
      var row2 = result[1];

      expect(row1[0], equals(value1));
      expect(row2[0], equals(value2));
    });
  });
}
