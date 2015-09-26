library dart_mysql.all_tests;

import 'protocol/buffer_reader_test.dart' as protocol__buffer_reader_test;
import 'protocol/buffer_writer_test.dart' as protocol__buffer_writer_test;
import 'protocol/connection_test.dart' as protocol__connection_test;
import 'protocol/packet_test.dart' as protocol__packet_test;
import 'protocol/server_bus_test.dart' as protocol__server_bus_test;

void main() {
  protocol__buffer_reader_test.main();
  protocol__buffer_writer_test.main();
  protocol__connection_test.main();
  protocol__packet_test.main();
  protocol__server_bus_test.main();
}
