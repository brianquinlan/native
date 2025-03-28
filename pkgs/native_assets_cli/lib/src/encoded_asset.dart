// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'hook/syntax.g.dart' as syntax;
import 'utils/json.dart';

/// An encoding of a particular asset type.
final class EncodedAsset {
  /// The type of the asset (e.g. whether it's a code asset, data asset or ...)
  final String type;

  /// The json encoding of the asset.
  final Map<String, Object?> encoding;

  /// The path of this object in a larger JSON.
  ///
  /// If provided, used for more precise error messages.
  final List<Object>? jsonPath;

  EncodedAsset(this.type, this.encoding, {this.jsonPath});

  /// Decode an [EncodedAsset] from json.
  factory EncodedAsset.fromJson(
    Map<String, Object?> json, [
    List<Object>? path,
  ]) {
    final syntax_ = syntax.Asset.fromJson(json);
    return EncodedAsset(syntax_.type, {
      for (final key in json.keys)
        if (key != _typeKey) key: json[key],
    }, jsonPath: path);
  }

  /// Encode this [EncodedAsset] tojson.
  Map<String, Object?> toJson() =>
      {for (final key in encoding.keys) key: encoding[key], _typeKey: type}
        ..sortOnKey();

  @override
  String toString() => 'EncodedAsset($type, $encoding)';

  // TODO(https://github.com/dart-lang/native/issues/2045): Fix this.
  @override
  int get hashCode => Object.hash(type, const DeepCollectionEquality().hash);

  @override
  bool operator ==(Object other) =>
      other is EncodedAsset &&
      type == other.type &&
      const DeepCollectionEquality().equals(encoding, other.encoding);
}

const String _typeKey = 'type';
