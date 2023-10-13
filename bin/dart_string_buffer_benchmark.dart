import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_string_buffer_benchmark/dart_string_buffer_benchmark.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Show this help message and exit')
    ..addOption(
      'max',
      abbr: 'm',
      help: 'Max number of iterations',
      defaultsTo: '1000',
    )
    ..addOption(
      'step',
      abbr: 's',
      help: 'Step of iterations',
      defaultsTo: '100',
    )
    ..addOption(
      'repeat',
      abbr: 'r',
      help: 'Number of repeats for each iteration',
      defaultsTo: '10',
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Output csv file name',
      defaultsTo: 'benchmark.csv',
    )
    ..addOption(
      'type',
      abbr: 't',
      help: 'Benchmark type',
      allowed: BenchmarkType.values.map(
        (e) => e.name,
      ),
      defaultsTo: BenchmarkType.all.name,
    )
    ..addFlag(
      'visualize',
      abbr: 'v',
      help: 'Visualize benchmark result. Output png file will be created.',
    )
    // stop before end of benchmark
    ..addFlag(
      'debug',
      abbr: 'd',
      help: 'Debug mode (stop before end of benchmark)',
    );

  final results = parser.parse(arguments);
  final args = BenchmarkParameter.fromResults(results);
  if (args.help) {
    print(parser.usage);
    exit(0);
  }

  await StringBufferBenchmark().run(
    args,
  );
  if (args.visualize) {
    // run python script
    final process = await Process.start(
      'python3',
      [
        'visualization/src/visualization/main.py',
      ],
    );
  }
}
