// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('link mode preference', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final resultDynamic =
          (await build(
            packageUri,
            logger,
            dartExecutable,
            linkModePreference: LinkModePreference.dynamic,
            buildAssetTypes: [BuildAssetType.code],
          )).success;

      final resultPreferDynamic =
          (await build(
            packageUri,
            logger,
            dartExecutable,
            linkModePreference: LinkModePreference.preferDynamic,
            buildAssetTypes: [BuildAssetType.code],
          )).success;

      final resultStatic =
          (await build(
            packageUri,
            logger,
            dartExecutable,
            linkModePreference: LinkModePreference.static,
            buildAssetTypes: [BuildAssetType.code],
          )).success;

      final resultPreferStatic =
          (await build(
            packageUri,
            logger,
            dartExecutable,
            linkModePreference: LinkModePreference.preferStatic,
            buildAssetTypes: [BuildAssetType.code],
          )).success;

      // This package honors preferences.
      expect(
        CodeAsset.fromEncoded(resultDynamic.encodedAssets.single).linkMode,
        DynamicLoadingBundled(),
      );
      expect(
        CodeAsset.fromEncoded(
          resultPreferDynamic.encodedAssets.single,
        ).linkMode,
        DynamicLoadingBundled(),
      );
      expect(
        CodeAsset.fromEncoded(resultStatic.encodedAssets.single).linkMode,
        StaticLinking(),
      );
      expect(
        CodeAsset.fromEncoded(resultPreferStatic.encodedAssets.single).linkMode,
        StaticLinking(),
      );
    });
  });
}
