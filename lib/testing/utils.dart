library dart_mysql.testing.utils;

import 'package:dart_mysql/protocol/packet.dart';
import 'package:dart_mysql/protocol/buffer_writer.dart';

Packet createColumnDefPacket(
    schema, tableName, columnName, columnLength, columnType,
    {virtualTableName,
    virtualColumnName,
    characterSet: 33,
    flags: 0x0000,
    decimals: 0}) {
  if (virtualColumnName == null) virtualColumnName = columnName;
  if (virtualTableName == null) virtualTableName = tableName;

  var writer = new BufferWriter();

  writer.writeLenencString('def');
  writer.writeLenencString(schema);
  writer.writeLenencString(virtualTableName);
  writer.writeLenencString(tableName);
  writer.writeLenencString(virtualColumnName);
  writer.writeLenencString(columnName);
  writer.writeLenencInt(0x0c);
  writer.writeInt2(characterSet);
  writer.writeInt4(columnLength);
  writer.writeInt1(columnType.value);
  writer.writeInt2(flags);
  writer.writeInt1(decimals);
  writer.fill(2);

  return new Packet(writer.buffer.length, 0, writer.buffer);
}

Packet createResultRowPacket(List<String> values) {
  var writer = new BufferWriter();

  for (var value in values) {
    writer.writeLenencString(value);
  }

  return new Packet(writer.buffer.length, 0, writer.buffer);
}
