library dart_mysql.all_tests;

import 'protocol/buffer_reader_test.dart' as protocol__buffer_reader_test;
import 'protocol/buffer_writer_test.dart' as protocol__buffer_writer_test;
import 'protocol/column_type_test.dart' as protocol__column_type_test;
import 'protocol/connection_test.dart' as protocol__connection_test;
import 'protocol/packet_test.dart' as protocol__packet_test;
import 'protocol/server_bus_test.dart' as protocol__server_bus_test;
import 'query/column_def_test.dart' as query__column_def_test;
import 'query/query_handler_test.dart' as query__query_handler_test;
import 'query/result_row_test.dart' as query__result_row_test;
import 'query/type_parser_test.dart' as query__type_parser_test;

void main() {
  protocol__buffer_reader_test.main();
  protocol__buffer_writer_test.main();
  protocol__column_type_test.main();
  protocol__connection_test.main();
  protocol__packet_test.main();
  protocol__server_bus_test.main();

  query__column_def_test.main();
  query__query_handler_test.main();
  query__result_row_test.main();
  query__type_parser_test.main();
}
