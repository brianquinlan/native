// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

class Metadata {
  final Map<String, Object?> metadata;

  const Metadata(this.metadata);

  factory Metadata.fromJson(Map<String, Object?>? jsonMap) =>
      Metadata(jsonMap ?? {});

  Map<String, Object?> toJson() => metadata;

  @override
  bool operator ==(Object other) {
    if (other is! Metadata) {
      return false;
    }
    return const DeepCollectionEquality().equals(other.metadata, metadata);
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(metadata);

  @override
  String toString() => 'Metadata(${toJson()})';
}
