/// @file library.dart
///
/// This file has helper(utility) functions that are independant from
/// - `service.dart`
/// - and the project.
///
import 'dart:convert';
import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/services.dart' show rootBundle;

/// Returns a random string
///
///
String randomString({int len = 8, String prefix}) {
  const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
  var t = '';
  for (var i = 0; i < len; i++) {
    t += charset[(Random().nextInt(charset.length))];
  }
  if (prefix != null && prefix.isNotEmpty) t = prefix + t;
  return t;
}

/// Returns true if [obj] is one of null, false, empty string, or 0.
bool isEmpty(obj) {
  return obj == null ||
      obj == '' ||
      obj == false ||
      obj == 0 ||
      (obj is List && obj.length == 0);
}

dynamic routerArguments(context) {
  return ModalRoute.of(context).settings.arguments;
}

/// 하나의 배열(List)를 여러개의 작은 배열로 나누는 함수
///
/// ```dart
/// List<dynamic> chunks = chunk(files, batch);
/// for (List<String> c in chunks) print(c);
/// ```
///
/// ```dart
/// chunk([], 1);
/// ```
List<T> chunk<T>(List list, int chunkSize) {
  List<dynamic> chunks = [];
  int len = list.length;
  for (var i = 0; i < len; i += chunkSize) {
    int size = i + chunkSize;
    chunks.add(list.sublist(i, size > len ? len : size));
  }
  return chunks;
}

/// Replaces the last [from] to [to] in [string].
///
/// ```dart
/// replaceLast('abcdefg abcdefg', 'abc', 'ABC');
/// ```
/// Result: abcdefg ABCefg
///
/// Dart has [replaceAll] and [replaceFrist] but no [replaceLast].
String replaceLast(String string, String from, String to) {
  int lastIndex = string.lastIndexOf(from);
  if (lastIndex < 0) return string;
  String tail = string.substring(lastIndex).replaceFirst(from, to);
  return string.substring(0, lastIndex) + tail;
}

/// Display short date
///
/// If it is today, then it dispays `YYYY-MM-DD HH:II AP`
/// If not, `YY-MM-DD` will be returned.
/// @param stamp unix timestamp
String shortDate(int stamp) {
  var _today = DateTime.now();

  /// 오늘 날짜
  var _date = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);

  /// 입력된 날짜
  var _dt = _date.toString();

  /// 입력된 날짜를 문자열로 변경
  /// 입력된 날짜가 오늘 날짜이면, 시/분을 리턴
  if (_date.year == _today.year &&
      _date.month == _today.month &&
      _date.day == _today.day) {
    return _dt.substring(11, 16);
  } else {
    /// 아니면, 년/월/일을 리턴
    return _dt.substring(0, 10);
  }
}

/// 문자열의 일부를 리턴한다.
///
/// [str] 원본 문자열
/// [startIndex] 리턴 할 시작 점
/// [len] 글 길이
///
/// Dart 의 [String.substring] 은 글자 수가 끝 길이 보다 크면, 에러가 난다.
///
/// 리턴 할 값이 없으면 빈 문자열을 리턴한다.
String substr(String str, int startIndex, [int len = 0]) {
  if (str == null || str.length == 0) return '';
  if (startIndex >= str.length) return '';
  int endIndex = 0;
  if (len == 0) {
    endIndex = str.length;
  } else {
    endIndex = startIndex + len;
  }
  if (endIndex >= str.length) endIndex = str.length;
  // print('str.lenth: ${str.length}, len: $len, endINdex: $endIndex');
  return str.substring(startIndex, endIndex);
}

/// 문자열에서 URL 을 추출하여 Set 으로 리턴
///
/// Return urls in a string
///
///   - ignores url inside of an html tag.
///
/// returns - set of string
///   - empty set if `str` is null or an empty string.
///   - set of urls with no duplicates.
///
///
Set<String> getUrls(String str) {
  if (str == null || str.isEmpty) return {};
  final urlRegEx = RegExp(
    r'''(?<!=")(\bhttps?:\/\/[\w-?&;#~=\.\/\@]+[\w\/])''',
    multiLine: true,
    caseSensitive: true,
  );
  var matches = urlRegEx.allMatches(str);
  return matches.map((m) => m.group(0)).toSet();
}

/// Generates a positive random integer uniformly distributed on the range
/// from [min], inclusive, to [max], exclusive.
int randomInt(int min, int max) {
  final _random = new Random();
  return min + _random.nextInt(max - min);
}

/// Loop a List with index
///
/// Dart can do loop on List but it does not provide index of the element.
/// This method provide index with element to the handler.
List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }
  return result;
}

/// 특정 시간에 한번 만 실행하는 함수
/// 예를 들어
///   - 1분에 한 번 만 실행하려는 경우,
///   - 12시 정각에 한 번 실행 하려고 하는데, 11시 59분 59초에 실행하려고 했다면,
///   - 12시 정각에 실행되지 않고, 12시 0분 59초에 실행되는 것으로 바뀐다.
///   - 또 12시 0분 59초가 되기 전인, 12시 0분 30초에 실행 하려고 했다면,
///   - 12시 1분 30초로 실행 시간이 바뀐다.
///   - 즉, 특정 시간까지 실행을 기다리는데, 그 전에 실행하려고 한다면, 실행하려는 시간을 늦춘다.
/// 참고: https://docs.google.com/document/d/148Vk8NX_RoyNKFrQZFR0lZsBzRARUljWH4kZMb4FI7M/edit#heading=h.cjnqi31f6urg
class Debouncer {
  final Duration delay;
  Timer _timer;
  Debouncer({this.delay});
  run(Function action, {dynamic seed}) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      action(seed);
    });
  }
}

/// 단어에서 첫 문자만 대문자로 변경한다.
/// 예) word -> Word
String fcUpperCase(String str) {
  return (str ?? '').length < 1 ? '' : str[0].toUpperCase() + str.substring(1);
}

/// 앱의 /assets 폴더에서 파일을 로드한다.
/// @example
/// ``` dart
/// loadAsset('MARKDOWN/expression/expression.md').then((content) {
///   setState(() => data = content);
/// }
/// ```
Future<String> loadAsset(String path) async {
  return await rootBundle.loadString(path);
}

/// Returns filename without extension.
///
/// @example
///   `/root/users/.../abc.jpg` returns `abc`
///
/// 파일 경로로 부터, 파일 명(확장자 제외)을 리턴한다.
/// 예) /root/users/.../abc.jpg 로 부터 abc 를 리턴한다.
String filenameFromPath(String path) {
  return path.split('/').last.split('.').first;
}

/// 핸드폰의 temporary 폴더에서 그 하위 경로로 파일 전체 경로를 리턴한다.
/// [path] must include the file extension.
/// @example
/// ``` dart
/// localFilePath('photo/baby.jpg');
/// ```
Future<String> localFilePath(String path) async {
  var directory = await getTemporaryDirectory();
  return p.join(directory.path, path);
}

/// 특정 local 임시 폴더에 있는 모든 파일을 읽어 들인다.
Future<List<String>> loadFiles(String folderName) async {
  List<String> files = [];
  var directory = await getTemporaryDirectory();
  var dir = io.Directory(p.join(directory.path, folderName));
  try {
    var dirList = dir.list();
    await for (io.FileSystemEntity f in dirList) {
      if (f is io.File) {
        files.add(f.path);
      } else if (f is io.Directory) {}
    }
  } catch (e) {
    // print(e.toString());
  }
  return files;
}

/// 핸드폰의 temporary 폴더에서 그 하위 경로의 파일이 존재하는지 확인을한다.
/// [path] must include the file extension.
/// @example
/// ``` dart
/// localfileExists('photo/baby.jpg');
/// ```
Future<bool> localfileExist(String path) async {
  var filePath = await localFilePath(path);
  // print(filePath);
  if (await io.File(filePath).exists()) {
    return true;
  } else {
    return false;
  }
}

/// Returns json from json file. JSON 파일을 읽어, JSON 으로 변환 후 리턴한다.
///
/// This will return `null` when there is no file or error.
Future readFileAsJson(String path) async {
  if (await localfileExist(path)) {
    String text = await io.File(await localFilePath(path)).readAsString();
    // print('text:');
    // print(text);
    return json.decode(text);
  } else {
    print('$path does not exists');
    return null;
  }
}

/// 파일의 내용을 읽어 문자열로 리턴한다.
Future readFileAsString(String path) async {
  if (await localfileExist(path)) {
    return await io.File(await localFilePath(path)).readAsString();
  } else {
    print('$path does not exists');
    return null;
  }
}

/// 정수를 받아들여 10 보다 작으면, 앞에 0을 붙이고,
/// 문자열로 변환해서 리턴한다.
String add0(int n) {
  if (n < 10)
    return '0$n';
  else
    return '$n';
}

/// Delays for some time
///
Future<void> delay([int milliseconds = 250]) async {
  await Future<void>.delayed(Duration(milliseconds: milliseconds));
}
