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
    for (var i = 1; i <= args.step; i += 1) {
      print('step: $i / ${args.step} (${i * stepCount} / ${args.max})');
      for (final type in types) {
        final result = _runBenchmark(
          i * stepCount,
          type,
          args.repeat,
        );
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

  BenchmarkResult _runBenchmark(
    int loop,
    BenchmarkType type,
    int repeat,
  ) {
    final stopwatch = Stopwatch()..start();
    switch (type) {
      case BenchmarkType.string:
        for (var i = 0; i < repeat; i++) {
          // ignore: unused_local_variable
          var buffer = '';
          for (var v = 0; v < loop; v++) {
            // ignore: use_string_buffers
            buffer += 'a';
          }
        }
      case BenchmarkType.stringBuffer:
        for (var i = 0; i < repeat; i++) {
          final buffer = StringBuffer();
          for (var v = 0; v < loop; v++) {
            buffer.write('a');
          }
        }
      case BenchmarkType.all:
        throw UnimplementedError();
    }
    stopwatch.stop();
    return BenchmarkResult(
      loop,
      (stopwatch.elapsedMicroseconds / 1000) / repeat,
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
