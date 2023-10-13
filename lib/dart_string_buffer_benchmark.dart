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
    if (args.debug) {
      print('Execution mode: debug');
      print('Max: ${args.max}');
      _runBenchmark(
        args.max,
        args.type,
        1,
        debug: args.debug,
      );
      exit(0);
    }
    for (var i = 1; i <= args.max; i += stepCount) {
      for (final type in types) {
        final result = _runBenchmark(
          i,
          type,
          args.repeat,
          debug: args.debug,
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
    int repeat, {
    bool debug = false,
  }) {
    final stopwatch = Stopwatch()..start();
    switch (type) {
      case BenchmarkType.string:
        // ignore: unused_local_variable
        var buffer = '';
        for (var i = 0; i < loop; i++) {
          // ignore: use_string_buffers
          buffer += 'a';
        }
        if (debug) {
          print('buffer: ${buffer.length}');
          print("DEBUG Ready: Press 'Enter' to continue.");
          // wait for enter key
          stdin.readLineSync();
        }
      case BenchmarkType.stringBuffer:
        final buffer = StringBuffer();
        for (var i = 0; i < loop; i++) {
          buffer.write('a');
        }
        if (debug) {
          print('buffer: ${buffer.length}');
          // wait for enter key
          stdin.readLineSync();
        }
      case BenchmarkType.all:
        throw UnimplementedError();
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
    required this.debug,
  });

  factory BenchmarkParameter.fromResults(ArgResults results) {
    final help = results['help'] as bool;
    final max = int.parse(results['max'] as String);
    final step = int.parse(results['step'] as String);
    final repeat = int.parse(results['repeat'] as String);
    final output = results['output'] as String;
    final type = results['type'] as String;
    final visualize = results['visualize'] as bool;
    final debug = results['debug'] as bool;
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
      debug: debug,
    );
  }
  final bool help;
  final int max;
  final int step;
  final int repeat;
  final String output;
  final BenchmarkType type;
  final bool visualize;
  final bool debug;
}
