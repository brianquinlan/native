// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

// TODO(https://github.com/dart-lang/native/issues/1435): Fix flakiness.
@Retry(3)

import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
import 'global_native_bindings.dart';
import 'util.dart';

void main() {
  group('global using @Native', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/objc_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      generateBindingsForCoverage('global_native');
    });

    test('Global string', () {
      expect(globalNativeString.toString(), 'Hello World');
      globalNativeString = 'Something else'.toNSString();
      expect(globalNativeString.toString(), 'Something else');
    });

    (Pointer<ObjCObject>, Pointer<ObjCObject>) globalObjectRefCountingInner() {
      final obj1 = NSObject.new1();
      globalNativeObject = obj1;
      final obj1raw = obj1.ref.pointer;
      expect(objectRetainCount(obj1raw), 2); // obj1, and the global variable.

      final obj2 = NSObject.new1();
      globalNativeObject = obj2;
      final obj2raw = obj2.ref.pointer;
      expect(objectRetainCount(obj2raw), 2); // obj2, and the global variable.
      expect(objectRetainCount(obj1raw), 1); // Just obj1.
      expect(obj1, isNotNull); // Force obj1 to stay in scope.
      expect(obj2, isNotNull); // Force obj2 to stay in scope.

      return (obj1raw, obj2raw);
    }

    test('Global object ref counting', () {
      final (obj1raw, obj2raw) = globalObjectRefCountingInner();
      doGC();

      expect(objectRetainCount(obj2raw), 1); // Just the global variable.
      expect(objectRetainCount(obj1raw), 0);

      globalNativeObject = null;
      expect(objectRetainCount(obj2raw), 0);
      expect(objectRetainCount(obj1raw), 0);
    }, skip: !canDoGC);

    test('Global block', () {
      globalNativeBlock = ObjCBlock_Int32_Int32.fromFunction((int x) => x * 10);
      expect(globalNativeBlock!(123), 1230);
      globalNativeBlock =
          ObjCBlock_Int32_Int32.fromFunction((int x) => x + 1000);
      expect(globalNativeBlock!(456), 1456);
    });

    (Pointer<ObjCBlockImpl>, Pointer<ObjCBlockImpl>)
        globalBlockRefCountingInner() {
      final blk1 = ObjCBlock_Int32_Int32.fromFunction((int x) => x * 10);
      globalNativeBlock = blk1;
      final blk1raw = blk1.ref.pointer;
      expect(blockRetainCount(blk1raw), 2); // blk1, and the global variable.

      final blk2 = ObjCBlock_Int32_Int32.fromFunction((int x) => x + 1000);
      globalNativeBlock = blk2;
      final blk2raw = blk2.ref.pointer;
      expect(blockRetainCount(blk2raw), 2); // blk2, and the global variable.
      expect(blockRetainCount(blk1raw), 1); // Just blk1.
      expect(blk1, isNotNull); // Force blk1 to stay in scope.
      expect(blk2, isNotNull); // Force blk2 to stay in scope.

      return (blk1raw, blk2raw);
    }

    test('Global block ref counting', () {
      final (blk1raw, blk2raw) = globalBlockRefCountingInner();
      doGC();

      expect(blockRetainCount(blk2raw), 1); // Just the global variable.
      expect(blockRetainCount(blk1raw), 0);

      globalNativeBlock = null;
      expect(blockRetainCount(blk2raw), 0);
      expect(blockRetainCount(blk1raw), 0);
    }, skip: !canDoGC);
  });
}
