// Copyright 2019 Gohilla.com team.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';
import 'dart:typed_data';

class Key {
  final Uint8List bytes;
  final bool isPublic;

  Key(this.bytes) : this.isPublic = false;

  Key.withPublicBytes(this.bytes) : this.isPublic = true;

  @override
  int get hashCode => bytes.length;

  @override
  operator ==(other) {
    if (other is Key) {
      return _byteListEqual(bytes, other.bytes);
    }
    return false;
  }

  /// Returns  string representation of the key.
  ///
  /// If [isPublic] is true, returns the result of [toBase64].
  ///
  /// Otherwise a static string so developers don't accidentally print secrets
  /// keys.
  @override
  String toString() {
    if (isPublic) {
      return "Key('${toBase64()}')";
    }
    return "Key('some bytes')";
  }

  /// Returns a Key from the base64 representation
  static Key fromBase64(String encoded, bool isPublic) {
    final bytes = base64.decode(encoded);
    if (isPublic) return Key.withPublicBytes(bytes);
    return Key(bytes);
  }

  /// Returns a base64 representation of the bytes.
  String toBase64() {
    return base64.encode(this.bytes);
  }

  static bool _byteListEqual(List<int> left, List<int> right) {
    if (left.length != right.length) {
      return false;
    }
    var result = true;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) {
        result = false;
      }
    }
    return result;
  }
}

/// Holds a secret key and a public key.
class AsymmetricKeyPair {
  final Key publicKey;
  final Key secretKey;

  AsymmetricKeyPair({this.secretKey, this.publicKey})
      : assert(secretKey != null),
        assert(publicKey != null);

  @override
  int get hashCode => publicKey.hashCode;

  @override
  operator ==(other) =>
      other is AsymmetricKeyPair &&
      secretKey == other.secretKey &&
      publicKey == other.publicKey;
}
