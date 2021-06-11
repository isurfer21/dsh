import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

const appAuthor = 'Abhishek Kumar';
const appVersion = '1.0.0';
const appHelp = """
Concatenate and print (display) the content of files

Concatenate FILE(s), or standard input, to standard output. With no FILE, or when FILE is -, read standard input.

Usage:
  dsh cat [options] FILE

Options:
""";

const flagLineNumber = 'number';
const flagHelp = 'help';
const flagVersion = 'version';

void main(List<String> arguments) {
  exitCode = 0; // presume success
  final parser = ArgParser()
    ..addFlag(flagHelp, negatable: false, abbr: 'h', help: 'show help')
    ..addFlag(flagVersion, negatable: false, abbr: 'v', help: 'show version')
    ..addFlag(flagLineNumber, negatable: false, abbr: 'n', help: 'number all output lines');

  ArgResults argResults = parser.parse(arguments);

  if (argResults[flagHelp] as bool) {
    stdout.writeln('${appHelp}${parser.usage}');
  } else if (argResults[flagVersion] as bool) {
    stdout.writeln(
        'Cat (Version ${appVersion}) \n© 2021 ${appAuthor} under MIT License.');
  } else {
    final paths = argResults.rest;
    dcat(paths, showLineNumbers: argResults[flagLineNumber] as bool);
  }
}

Future<void> dcat(List<String> paths, {bool showLineNumbers = false}) async {
  if (paths.isEmpty) {
    // No files provided as arguments. Read from stdin and print each line.
    await stdin.pipe(stdout);
  } else {
    for (final path in paths) {
      var lineNumber = 1;
      final lines = utf8.decoder
          .bind(File(path).openRead())
          .transform(const LineSplitter());
      try {
        await for (final line in lines) {
          if (showLineNumbers) {
            stdout.write('${lineNumber++} ');
          }
          stdout.writeln(line);
        }
      } catch (_) {
        await _handleError(path);
      }
    }
  }
}

Future<void> _handleError(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.writeln('error: $path is a directory');
  } else {
    exitCode = 2;
  }
}
