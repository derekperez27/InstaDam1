import 'dart:io';

void main() {
  final f = File('lib/screens/login_screen.dart');
  if (!f.existsSync()) {
    stdout.writeln('file not found');
    return;
  }
  final s = f.readAsStringSync();
  final counts = {'(': 0, ')': 0, '{': 0, '}': 0, '[': 0, ']': 0};
  for (var r in s.runes) {
    final ch = String.fromCharCode(r);
    if (counts.containsKey(ch)) counts[ch] = counts[ch]! + 1;
  }
  stdout.writeln(counts);
}
