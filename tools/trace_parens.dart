import 'dart:io';

void main() {
  final s = File('lib/screens/login_screen.dart').readAsStringSync();
  final lines = s.split('\n');
  final stack = <MapEntry<String, int>>[];
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    for (int j = 0; j < line.length; j++) {
      final ch = line[j];
      if (ch == '(' || ch == '{' || ch == '[') stack.add(MapEntry(ch, i + 1));
      if (ch == ')' || ch == '}' || ch == ']') {
        if (stack.isEmpty) {
          stdout.writeln('Unmatched closing $ch at line ${i + 1}');
        } else {
          final top = stack.removeLast();
          final open = top.key;
          if ((open == '(' && ch != ')') || (open == '{' && ch != '}') || (open == '[' && ch != ']')) {
            stdout.writeln('Mismatch $open..$ch at line ${i + 1} (opened at line ${top.value})');
          }
        }
      }
    }
    if ((i + 1) % 5 == 0) {
      stdout.writeln('line ${i + 1} stack: ${stack.map((e) => '${e.key}@${e.value}').join(',')}');
    }
  }
  if (stack.isNotEmpty) {
    stdout.writeln('Remaining stack at EOF: ${stack.map((e) => '${e.key}@${e.value}').join(',')}');
  } else {
    stdout.writeln('All matched');
  }
}
