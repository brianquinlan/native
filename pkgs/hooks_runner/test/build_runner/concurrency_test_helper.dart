// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:data_assets/data_assets.dart';
import 'package:file/local.dart';
import 'package:hooks_runner/hooks_runner.dart';
import 'package:logging/logging.dart';

import '../helpers.dart';
import 'helpers.dart';

// Is invoked concurrently multiple times in separate processes.
void main(List<String> args) async {
  final packageUri = Uri.directory(args[0]);
  final packageName = packageUri.pathSegments.lastWhere((e) => e.isNotEmpty);
  Duration? timeout;
  if (args.length >= 2) {
    timeout = Duration(milliseconds: int.parse(args[1]));
  }

  final logger =
      Logger('')
        ..level = Level.ALL
        ..onRecord.listen((event) => print(event.message));

  final targetOS = OS.current;
  final packageLayout = await PackageLayout.fromWorkingDirectory(
    const LocalFileSystem(),
    packageUri,
    packageName,
  );
  final result = await NativeAssetsBuildRunner(
    logger: logger,
    dartExecutable: dartExecutable,
    singleHookTimeout: timeout,
    fileSystem: const LocalFileSystem(),
    packageLayout: packageLayout,
  ).build(
    extensions: [
      CodeAssetExtension(
        targetArchitecture: Architecture.current,
        targetOS: targetOS,
        linkModePreference: LinkModePreference.dynamic,
        cCompiler: dartCICompilerConfig,
        macOS:
            targetOS == OS.macOS
                ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
                : null,
      ),
      DataAssetsExtension(),
    ],
    linkingEnabled: false,
  );
  if (result.isFailure) {
    throw Error();
  }
  print('done');
}
