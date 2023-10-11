import 'dart:io';
import 'dart:math';

class StringBufferBenchmark {
  Future<void> run({int max = 1000}) async {
    final results = <BenchmarkResult>[];
    final step = max ~/ 100;
    for (var i = 1; i <= max; i += step) {
      results
        ..add(_runBenchmark(i, BenchmarkType.string))
        ..add(_runBenchmark(i, BenchmarkType.stringBuffer));
    }
    for (final result in results) {
      print('${result.type}, ${result.loop}, ${result.time}ms');
    }
    // output as csv
    final csv = [
      'type,x,y',
      ...results.map((e) => '${e.type},${e.loop},${e.time}'),
    ].join('\n');
    final file = File('benchmark.csv');
    await file.writeAsString(csv);
  }

  BenchmarkResult _runBenchmark(int loop, BenchmarkType type) {
    final stopwatch = Stopwatch()..start();
    final random = Random();
    switch (type) {
      case BenchmarkType.string:
        var buffer = '';
        for (var i = 0; i < loop; i++) {
          // ignore: use_string_buffers
          buffer += random.nextInt(10).toString();
        }
        final _ = buffer;
      case BenchmarkType.stringBuffer:
        final buffer = StringBuffer();
        for (var i = 0; i < loop; i++) {
          buffer.write(random.nextInt(10).toString());
        }
        final _ = buffer.toString();
    }
    stopwatch.stop();
    return BenchmarkResult(loop, stopwatch.elapsedMicroseconds / 1000, type);
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
  ;
}
