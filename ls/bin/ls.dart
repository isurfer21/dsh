import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:args/args.dart';

const appAuthor = 'Abhishek Kumar';
const appVersion = '1.0.0';
const appHelp = """

List information about file(s)

It displays a list of files and sub-directories in a directory which could be 
rendered in various ways based on passed options.

Usage:
  ush ls [options]

Options:
""";

const flagHelp = 'help';
const flagVersion = 'version';
const flagColumn = 'column';
const flagCsv = 'csv';
const flagExist = 'exist';
const flagLine = 'line';
const flagLong = 'long';

void main(List<String> arguments) {
  exitCode = 0; // presume success
  final parser = ArgParser()
    ..addFlag(flagHelp, negatable: false, abbr: 'h', help: 'show help')
    ..addFlag(flagVersion, negatable: false, abbr: 'v', help: 'show version')
    ..addFlag(flagColumn,
        negatable: false, abbr: 'C', help: 'list entries by columns (vertical)')
    ..addFlag(flagCsv,
        negatable: false, abbr: 'm', help: 'comma separated list of entries')
    ..addFlag(flagExist,
        negatable: false,
        abbr: 'e',
        help: 'returns true/false based on path existence')
    ..addFlag(flagLine,
        negatable: false, abbr: '1', help: 'list entries by lines (horizontal)')
    ..addFlag(flagLong,
        negatable: false, abbr: 'l', help: 'use a long listing format');

  ArgResults argResults = parser.parse(arguments);

  if (argResults[flagHelp] as bool) {
    stdout.writeln('${appHelp}${parser.usage}');
  } else if (argResults[flagVersion] as bool) {
    stdout.writeln(
        'Ls (Version ${appVersion}) \n© 2021 ${appAuthor} under MIT License.');
  } else {
    final paths = argResults.rest;
    ls(paths,
        showAsColumn: argResults[flagColumn] as bool,
        showAsCsv: argResults[flagCsv] as bool,
        showAsExist: argResults[flagExist] as bool,
        showAsLine: argResults[flagLine] as bool,
        showAsLong: argResults[flagLong] as bool);
  }
}

String fileSize(size, [int round = 2, bool decimal = false]) {
  int divider = 1024;
  size = int.parse(size.toString());
  if (decimal) divider = 1000;
  if (size < divider) return "$size B";
  if (size < divider * divider && size % divider == 0)
    return "${(size / divider).toStringAsFixed(0)} KB";
  if (size < divider * divider)
    return "${(size / divider).toStringAsFixed(round)} KB";
  if (size < divider * divider * divider && size % divider == 0)
    return "${(size / (divider * divider)).toStringAsFixed(0)} MB";
  if (size < divider * divider * divider)
    return "${(size / divider / divider).toStringAsFixed(round)} MB";
  if (size < divider * divider * divider * divider && size % divider == 0)
    return "${(size / (divider * divider * divider)).toStringAsFixed(0)} GB";
  if (size < divider * divider * divider * divider)
    return "${(size / divider / divider / divider).toStringAsFixed(round)} GB";
  if (size < divider * divider * divider * divider * divider &&
      size % divider == 0)
    return "${(size / divider / divider / divider / divider).toStringAsFixed(0)} TB";
  if (size < divider * divider * divider * divider * divider)
    return "${(size / divider / divider / divider / divider).toStringAsFixed(round)} TB";
  if (size < divider * divider * divider * divider * divider * divider &&
      size % divider == 0) {
    return "${(size / divider / divider / divider / divider / divider).toStringAsFixed(0)} PB";
  } else {
    return "${(size / divider / divider / divider / divider / divider).toStringAsFixed(round)} PB";
  }
}

Future<void> ls(List<String> paths,
    {bool showAsColumn = false,
    bool showAsCsv = false,
    bool showAsExist = false,
    bool showAsLine = false,
    bool showAsLong = false}) async {
  if (paths.isEmpty) {
    paths = [Directory.current.path];
  }
  for (final path in paths) {
    if (showAsExist) {
      var isThere =
          (await File(path).exists()) ? true : (await Directory(path).exists());
      print(isThere ? 'true' : 'false');
    } else {
      try {
        var dir = Directory(path);
        var dirList = dir.list();
        if (showAsLong) {
          List<String> output = [];
          int maxColLen = 12;
          await for (FileSystemEntity f in dirList) {
            var outCol = [];
            if (f is File) {
              var cfile = File(f.path);
              var fileStat = cfile.statSync();
              outCol.add(fileStat.modeString());
              outCol.add(fileSize(fileStat.size).padRight(maxColLen));
              var fileDate = fileStat.changed.toString();
              fileDate = fileDate.substring(0, fileDate.indexOf('.'));
              outCol.add(fileDate);
              outCol.add(fileStat.type.toString().substring(0, 4));
              outCol.add(basename(cfile.path));
            } else if (f is Directory) {
              var cdir = Directory(f.path);
              var dirStat = cdir.statSync();
              outCol.add(dirStat.modeString());
              outCol.add('-'.padRight(maxColLen));
              var dirDate = dirStat.changed.toString();
              dirDate = dirDate.substring(0, dirDate.indexOf('.'));
              outCol.add(dirDate);
              outCol.add(dirStat.type.toString().substring(0, 3) + ' ');
              outCol.add(basename(cdir.path));
            }
            output.add(outCol.join('\t'));
          }
          print(output.join('\n'));
        } else {
          List<String> output = [];
          await for (FileSystemEntity f in dirList) {
            if (f is File) {
              output.add(basename(f.path));
            } else if (f is Directory) {
              output.add(basename(f.path));
            }
          }
          if (showAsLine) {
            print(output.join('\n'));
          } else if (showAsCsv) {
            print(output.join(', '));
          } else if (showAsColumn) {
            int maxColLen = 0;
            for (final item in output) {
              maxColLen = max(maxColLen, item.length);
            }
            for (int i = 0; i < output.length; i++) {
              output[i] = output[i].padRight(maxColLen);
            }
            var maxTermWidth = stdout.terminalColumns;
            int maxColInLine = (maxTermWidth / maxColLen).floor();
            int widthWithSpace = maxColInLine * maxColLen + maxColInLine;
            var dafaultSeparator = (widthWithSpace < maxTermWidth) ? ' ' : '';
            var modifiedOutput = '';
            for (int i = 0; i < output.length; i++) {
              var separator = dafaultSeparator;
              if ((i + 1).remainder(maxColInLine) == 0) {
                separator = '\n';
              }
              modifiedOutput += output[i] + separator;
            }
            print(modifiedOutput);
          } else {
            print(output.join('\t'));
          }
        }
      } catch (e) {
        print(e.toString());
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
