import 'dart:io';

final procDir = Directory('/proc');

typedef ProcMap = Map<String, dynamic>;

Future<Map<int, ProcMap>> getProcessInfo() async {
  var m = <int, ProcMap>{};

  await for (var d in procDir.list()) {
    var proc = d.path.split('/').last;
    var pid = int.tryParse(proc);
    if (pid != null) {
      m[pid] = await parseProcStat(pid);
    }
  }
  return m;
}

Future<ProcMap> parseProcStat(int pid) async {
  final filePath = '/proc/$pid/stat';

  try {
    final lines = await File(filePath).readAsLines();

    if (lines.isEmpty) {
      throw Exception('Could not read lines from $filePath');
    }

    final statLine = lines.first;
    final values = statLine.split(' ').toList();

    // Reference: https://man7.org/linux/man-pages/man5/proc.5.html#proc_pid_stat
    return {
      'pid': int.parse(values[0]),
      'comm': values[1],
      'state': values[2],
      'ppid': int.parse(values[3]),
      'pgrp': int.parse(values[4]),
      'session': int.parse(values[5]),
      'tty_nr': int.parse(values[6]),
      'tpgid': int.parse(values[7]),
      'flags': int.parse(values[8]),
      'minflt': int.parse(values[9]),
      'majflt': int.parse(values[10]),
      'utime': int.parse(values[11]),
      'stime': int.parse(values[12]),
      'cutime': int.parse(values[13]),
      'cstime': int.parse(values[14]),
      'priority': int.parse(values[15]),
      'nice': int.parse(values[16]),
      'num_threads': int.parse(values[17]),
      'itrealvalue': int.parse(values[18]),
      'starttime': int.parse(values[19]),
      'vsize': int.parse(values[20]),
      'rss': int.parse(values[21]),
      'rsslim': int.parse(values[22]),
      // these are large - need to be bigint or a string..
      'startcode': values[23],
      'endcode': values[24],
      'startstack': values[25],
      'kstespts': values[26],
      'kstackesp': values[27],
      'kstkeip': values[28],
      'signal': int.parse(values[29]),
      'blocked': int.parse(values[30]),
      'sigignore': int.parse(values[31]),
      'sigcatch': int.parse(values[32]),
      'wchan': int.parse(values[33]),
      'nswap': values[34],
      'cnswap': values[35],
      'exit_signal': int.parse(values[36]),
      'processor': int.parse(values[37]),
      'rt_priority': int.parse(values[38]),
      'policy': int.parse(values[39]),
      'delayacct_blkio_ticks': int.parse(values[40]),
      'guest_time': int.parse(values[41]),
      'cguest_time': int.parse(values[42]),
      'start_time': int.parse(values[43]),
      'vruntime': int.parse(values[44]),
      // ... further process fields if needed
    };
  } catch (error) {
    print('Error parsing $filePath: $error');
    rethrow; // Rethrow the error for proper handling
  }
}
