import 'dart:io';

import 'package:args/args.dart';

class StringBufferBenchmark {
  Future<void> run(BenchmarkParameter args) async {
    // 1 stepで増やすiteration数
    final stepCount = args.max ~/ args.step;

    final types = switch (args.type) {
      BenchmarkType.all => [...BenchmarkType.values]..remove(BenchmarkType.all),
      _ => [args.type],
    };

    final results = <BenchmarkResult>[];
    for (var i = 1; i <= args.max; i += stepCount) {
      for (final type in types) {
        final result = _runBenchmark(i, type, args.repeat);
        results.add(result);
      }
    }
    await _outputAsCsv(args.output, results);
  }

  Future<void> _outputAsCsv(
    String filename,
    List<BenchmarkResult> results,
  ) async {
    final csv = [
      'type,loop,time',
      ...results.map((e) => '${e.type},${e.loop},${e.time}'),
    ].join('\n');
    final file = File(filename);
    await file.writeAsString(csv);
  }

  BenchmarkResult _runBenchmark(int loop, BenchmarkType type, int repeat) {
    final stopwatch = Stopwatch()..start();
    for (var i = 0; i < loop; i++) {
      switch (type) {
        case BenchmarkType.string:
          // ignore: unused_local_variable
          var buffer = '';
          for (var i = 0; i < loop; i++) {
            // ignore: use_string_buffers
            buffer += 'a';
          }
        case BenchmarkType.stringBuffer:
          final buffer = StringBuffer();
          for (var i = 0; i < loop; i++) {
            buffer.write('a');
          }
        case BenchmarkType.all:
          throw UnimplementedError();
      }
    }
    stopwatch.stop();
    return BenchmarkResult(
      loop,
      stopwatch.elapsedMicroseconds / 1000 / repeat,
      type,
    );
  }
}

class BenchmarkResult {
  BenchmarkResult(this.loop, this.time, this.type);

  final int loop;

  /// in milliseconds
  final double time;

  final BenchmarkType type;
}

enum BenchmarkType {
  string,
  stringBuffer,
  all,
  ;
}

class BenchmarkParameter {
  BenchmarkParameter({
    required this.help,
    required this.max,
    required this.step,
    required this.repeat,
    required this.output,
    required this.type,
    required this.visualize,
  });

  factory BenchmarkParameter.fromResults(ArgResults results) {
    final help = results['help'] as bool;
    final max = int.parse(results['max'] as String);
    final step = int.parse(results['step'] as String);
    final repeat = int.parse(results['repeat'] as String);
    final output = results['output'] as String;
    final type = results['type'] as String;
    final visualize = results['visualize'] as bool;
    return BenchmarkParameter(
      help: help,
      max: max,
      step: step,
      repeat: repeat,
      output: output,
      type: BenchmarkType.values.firstWhere(
        (e) => e.name == type,
      ),
      visualize: visualize,
    );
  }
  final bool help;
  final int max;
  final int step;
  final int repeat;
  final String output;
  final BenchmarkType type;
  final bool visualize;
}
