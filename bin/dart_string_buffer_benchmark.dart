import 'dart:math';

import 'package:dart_string_buffer_benchmark/dart_string_buffer_benchmark.dart'
    as dart_string_buffer_benchmark;

void main(List<String> arguments) async =>
    dart_string_buffer_benchmark.StringBufferBenchmark().run(
      max: pow(2, 20).toInt(),
    );
