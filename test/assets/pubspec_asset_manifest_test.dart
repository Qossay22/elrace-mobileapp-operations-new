import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String pubspec;

  setUpAll(() {
    pubspec = File('pubspec.yaml').readAsStringSync();
  });

  test('keeps heavyweight json and antispoof asset folders explicit', () {
    expect(pubspec, isNot(contains('    - assets/json/\n')));
    expect(pubspec, isNot(contains('    - assets/antispoof/\n')));
    expect(pubspec, isNot(contains('    - assets/gif/\n')));

    expect(pubspec, contains('assets/json/blink.json'));
    expect(pubspec, contains('assets/json/face_detecting.json'));
    expect(pubspec, contains('assets/json/hold.json'));
    expect(pubspec, contains('assets/json/inside.json'));
    expect(pubspec, contains('assets/json/left.json'));
    expect(pubspec, contains('assets/json/right.json'));
    expect(pubspec, contains('assets/json/smile.json'));
    expect(
        pubspec, contains('assets/antispoof/minifasnet_v1se_4.0_80x80.tflite'));
    expect(
        pubspec, contains('assets/antispoof/minifasnet_v2_2.7_80x80.tflite'));
    expect(pubspec, contains('assets/gif/ai.gif'));
    expect(pubspec, contains('assets/gif/arrow_animation.gif'));
    expect(pubspec, contains('assets/gif/el-race-logo.gif'));
    expect(pubspec, contains('assets/gif/finger-print.gif'));
  });

  test('does not bundle known oversized unused model and animation files', () {
    expect(pubspec, isNot(contains('assets/json/logo.json')));
    expect(pubspec, isNot(contains('assets/mobilefacenet.tflite')));
    expect(pubspec, isNot(contains('assets/antispoof/_tf_MiniFASNetV1SE')));
    expect(pubspec, isNot(contains('assets/antispoof/_tf_MiniFASNetV2')));
  });
}
