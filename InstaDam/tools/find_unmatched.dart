import 'dart:io';

void main() {
  final f = File('lib/screens/login_screen.dart');
  final s = f.readAsStringSync();
  final stack = <MapEntry<String, int>>[];
  for (int i = 0; i < s.length; i++) {
    final ch = s[i];
    if (ch == '(' || ch == '{' || ch == '[') stack.add(MapEntry(ch, i));
    if (ch == ')' || ch == '}' || ch == ']') {
      if (stack.isEmpty) {
        stdout.writeln('Unmatched closing $ch at index $i');
        return;
      }
      final top = stack.removeLast();
      final open = top.key;
      if ((open == '(' && ch != ')') || (open == '{' && ch != '}') || (open == '[' && ch != ']')) {
        final prefix = s.substring(0, i);
        final line = '\n'.allMatches(prefix).length + 1;
        final col = i - (prefix.lastIndexOf('\n') + 1) + 1;
        final openPrefix = s.substring(0, top.value);
        final openLine = '\n'.allMatches(openPrefix).length + 1;
        final lines = s.split('\n');
        final startLine = (openLine - 2).clamp(1, lines.length);
        final endLine = (line + 2).clamp(1, lines.length);
        stdout.writeln('Mismatched pair $open...$ch at index $i (line $line, col $col). Last open $open at line $openLine.');
        stdout.writeln('Context lines $startLine..$endLine:');
        for (var ln = startLine; ln <= endLine; ln++) {
          stdout.writeln('${ln.toString().padLeft(4)} | ${lines[ln - 1]}');
        }
        return;
      }
    }
  }
  if (stack.isNotEmpty) {
    final last = stack.last;
    // print context
    final idx = last.value;
    // compute line and column
    final prefix = s.substring(0, idx);
    final line = '\n'.allMatches(prefix).length + 1;
    final col = idx - (prefix.lastIndexOf('\n') + 1) + 1;
    final lines = s.split('\n');
    final startLine = (line - 3).clamp(1, lines.length);
    final endLine = (line + 3).clamp(1, lines.length);
    stdout.writeln('Unmatched opening ${last.key} at index $idx (line $line, col $col)');
    stdout.writeln('Context lines $startLine..$endLine:');
    for (var ln = startLine; ln <= endLine; ln++) {
      stdout.writeln('${ln.toString().padLeft(4)} | ${lines[ln - 1]}');
    }
  } else {
    stdout.writeln('All matched');
  }
}
