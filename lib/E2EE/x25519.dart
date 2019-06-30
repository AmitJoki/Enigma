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

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'key.dart';

const x25519 = X25519();

/// Implements X25519 key exchange ([RFC 7748](https://tools.ietf.org/html/rfc7748)).
class X25519 {
  /// Constant [9, 0, ..., 0] is used when calculating shared secret.
  static final Uint8List _constant9 = () {
    final result = Uint8List(32);
    result[0] = 9;
    return result;
  }();

  /// Constant [0xdb41, 1, 0, ..., 0].
  static final Int32List _constant121665 = () {
    final result = Int32List(16);
    result[0] = 0xdb41;
    result[1] = 1;
    return result;
  }();

  /// A secure random number generator.
  static final Random _random = Random.secure();

  const X25519();

  /// Calculates the shared secret asynchronously.
  /// The method is asynchronous, which enables implementers to use
  /// platform-specific APIs and isolates.
  ///
  /// The synchronous version is [calculateSharedSecretSync].
  Future<Key> calculateSharedSecret(Key secretKey, Key publicKey) async {
    return calculateSharedSecretSync(secretKey, publicKey);
  }

  /// Calculates the shared secret synchronously.
  ///
  /// The asynchronous version is [calculateSharedSecret].
  Key calculateSharedSecretSync(Key secretKey, Key publicKey) {
    final secretKeyTransformed = Uint8List.fromList(secretKey.bytes);
    replaceSeedWithSecretKey(secretKeyTransformed);
    final result = Uint8List(32);
    _scalarMultiply(result, secretKeyTransformed, publicKey.bytes);
    return Key(result);
  }

  /// Generates a random Curve25519 keypair.
  /// The method is asynchronous, which enables implementers to use
  /// platform-specific APIs and isolates.
  ///
  /// If you need to perform the operation synchronously, use
  /// [generateKeyPairSync].
  Future<AsymmetricKeyPair> generateKeyPair({Uint8List seed}) async {
    return generateKeyPairSync(seed: seed);
  }

  /// Generates a random Curve25519 keypair synchronously.
  /// You can optionally give a seed, which is any 32-octet Uint8List.
  ///
  /// The use asynchronous version is [generateKeyPair].
  AsymmetricKeyPair generateKeyPairSync({Uint8List seed}) {
    if (seed == null) {
      // Generate 32 random bytes using a secure random number generator
      final random = X25519._random;
      seed = Uint8List(32);
      for (var i = 0; i < seed.length; i++) {
        seed[i] = random.nextInt(256);
      }
    } else {
      if (seed.length != 32) {
        throw ArgumentError("Seed must have 32 bytes");
      }

      // Create a copy of the seed
      seed = Uint8List.fromList(seed);
    }

    // Create a secret key
    replaceSeedWithSecretKey(seed);
    final secretKey = Key(seed);

    // Calculate public key
    final publicKeyBytes = Uint8List(32);
    _scalarMultiply(publicKeyBytes, seed, _constant9);

    // Return a keypair
    final publicKey = Key.withPublicBytes(publicKeyBytes);
    return AsymmetricKeyPair(secretKey: secretKey, publicKey: publicKey);
  }

  /// Modifies certain bits of seed so that the result is a valid secret key.
  static void replaceSeedWithSecretKey(Uint8List seed) {
    // First 3 bits should be 0
    seed[0] &= 0xf8;

    // Bit 254 should be 1
    seed[31] |= 0x40;

    // Bit 255 should be 0
    seed[31] &= 0x7f;
  }

  /// X25519 multiplication of two 32-octet scalar.
  ///
  /// Used by [generateKeyPairSync] and [calculateSharedSecretSync].
  static void _scalarMultiply(
    Uint8List result,
    Uint8List secretKey,
    Uint8List publicKey,
  ) {
    // Allocate temporary arrays
    final unpacked = Int32List(16);

    // -------------------------------------------------------------------------
    // Unpack public key into the internal Int32List
    // -------------------------------------------------------------------------

    for (var i = 0; i < 16; i++) {
      unpacked[i] = publicKey[2 * i] | (publicKey[2 * i + 1] << 8);
    }
    // Clear the last bit
    unpacked[15] &= 0x7FFF;

    // -------------------------------------------------------------------------
    // Calculate
    // -------------------------------------------------------------------------

    // Allocate temporary arrays
    final a = Int32List(16),
        b = Int32List(16),
        c = Int32List(16),
        d = Int32List(16),
        e = Int32List(16),
        f = Int32List(16);

    // Initialize 'b'
    for (var i = 0; i < 16; i++) {
      b[i] = unpacked[i];
    }

    // Initialize 'a' and 'd'
    a[0] = 1;
    d[0] = 1;

    // For each bit in 'secretKey'
    for (var i = 254; i >= 0; i--) {
      // Get the bit
      final bit = 1 & (secretKey[i >> 3] >> (7 & i));

      // if bit == 1:
      //   swap(a, b)
      //   swap(c, d)
      _conditionalSwap(a, b, bit);
      _conditionalSwap(c, d, bit);

      // e = a + c
      // a = a + c
      // c = b + d
      // b = b - d
      for (var i = 0; i < 16; i++) {
        final ai = a[i];
        final bi = b[i];
        final ci = c[i];
        final di = d[i];
        e[i] = ai + ci;
        a[i] = ai - ci;
        c[i] = bi + di;
        b[i] = bi - di;
      }

      // d = e^2
      // f = a^2
      // a = c * a
      // c = b * e
      _multiply(d, e, e);
      _multiply(f, a, a);
      _multiply(a, c, a);
      _multiply(c, b, e);

      // e = a + c
      // a = a - c
      // c = d - f
      for (var i = 0; i < 16; i++) {
        final ai = a[i];
        final ci = c[i];
        e[i] = ai + ci;
        a[i] = ai - ci;
        c[i] = d[i] - f[i];
      }

      // b = a^2
      _multiply(b, a, a);

      // a = c * _constant121665 + d
      _multiply(a, c, _constant121665);
      for (var i = 0; i < 16; i++) {
        a[i] += d[i];
      }

      // c = c * a
      // a = d * f
      // d = b * unpacked
      // b = e^2
      _multiply(c, c, a);
      _multiply(a, d, f);
      _multiply(d, b, unpacked);
      _multiply(b, e, e);

      // if bit == 1:
      //   swap(a, b)
      //   swap(c, d)
      _conditionalSwap(a, b, bit);
      _conditionalSwap(c, d, bit);
    }

    // Copy 'c' to 'd'
    for (var i = 0; i < 16; i++) {
      d[i] = c[i];
    }

    // 254 times
    for (var i = 253; i >= 0; i--) {
      // c = c^2
      _multiply(c, c, c);

      if (i != 2 && i != 4) {
        // c = c * d
        _multiply(c, c, d);
      }
    }

    // a = a * c
    _multiply(a, a, c);

    // 3 times
    for (var i = 0; i < 3; i++) {
      var x = 1;
      for (var i = 0; i < 16; i++) {
        final v = 0xFFFF + a[i] + x;
        x = v ~/ 0x10000;
        a[i] = v - 0x10000 * x;
      }
      a[0] += 38 * (x - 1);
    }

    // 2 times
    for (var i = 0; i < 2; i++) {
      // The first element
      var previous = a[0] - 0xFFED;
      b[0] = 0xFFFF & previous;

      // Subsequent elements
      for (var j = 1; j < 15; j++) {
        final current = a[j] - 0xFFFF - (1 & (previous >> 16));
        b[j] = 0xFFFF & current;
        previous = current;
      }

      // The last element
      b[15] = a[15] - 0x7FFF - (1 & (previous >> 16));

      // if isSwap == 1:
      //   swap(a, m)
      final isSwap = 1 - (1 & (b[15] >> 16));
      _conditionalSwap(a, b, isSwap);
    }

    // -------------------------------------------------------------------------
    // Pack the internal Int32List into result bytes
    // -------------------------------------------------------------------------
    for (var i = 0; i < 16; i++) {
      result[2 * i] = 0xFF & a[i];
      result[2 * i + 1] = a[i] >> 8;
    }
  }

  /// Constant-time conditional swap.
  ///
  /// If b is 0, the function does nothing.
  /// If b is 1, elements of the arrays will be swapped.
  static void _conditionalSwap(Int32List p, Int32List q, int b) {
    final c = ~(b - 1);
    for (var i = 0; i < 16; i++) {
      final t = c & (p[i] ^ q[i]);
      p[i] ^= t;
      q[i] ^= t;
    }
  }

  /// Constant-time multiplication of the two arguments.
  static void _multiply(Int32List result, Int32List a, Int32List b) {
    var t0 = 0,
        t1 = 0,
        t2 = 0,
        t3 = 0,
        t4 = 0,
        t5 = 0,
        t6 = 0,
        t7 = 0,
        t8 = 0,
        t9 = 0,
        t10 = 0,
        t11 = 0,
        t12 = 0,
        t13 = 0,
        t14 = 0,
        t15 = 0,
        t16 = 0,
        t17 = 0,
        t18 = 0,
        t19 = 0,
        t20 = 0,
        t21 = 0,
        t22 = 0,
        t23 = 0,
        t24 = 0,
        t25 = 0,
        t26 = 0,
        t27 = 0,
        t28 = 0,
        t29 = 0,
        t30 = 0,
        b0 = b[0],
        b1 = b[1],
        b2 = b[2],
        b3 = b[3],
        b4 = b[4],
        b5 = b[5],
        b6 = b[6],
        b7 = b[7],
        b8 = b[8],
        b9 = b[9],
        b10 = b[10],
        b11 = b[11],
        b12 = b[12],
        b13 = b[13],
        b14 = b[14],
        b15 = b[15];

    var v = a[0];
    t0 += v * b0;
    t1 += v * b1;
    t2 += v * b2;
    t3 += v * b3;
    t4 += v * b4;
    t5 += v * b5;
    t6 += v * b6;
    t7 += v * b7;
    t8 += v * b8;
    t9 += v * b9;
    t10 += v * b10;
    t11 += v * b11;
    t12 += v * b12;
    t13 += v * b13;
    t14 += v * b14;
    t15 += v * b15;
    v = a[1];
    t1 += v * b0;
    t2 += v * b1;
    t3 += v * b2;
    t4 += v * b3;
    t5 += v * b4;
    t6 += v * b5;
    t7 += v * b6;
    t8 += v * b7;
    t9 += v * b8;
    t10 += v * b9;
    t11 += v * b10;
    t12 += v * b11;
    t13 += v * b12;
    t14 += v * b13;
    t15 += v * b14;
    t16 += v * b15;
    v = a[2];
    t2 += v * b0;
    t3 += v * b1;
    t4 += v * b2;
    t5 += v * b3;
    t6 += v * b4;
    t7 += v * b5;
    t8 += v * b6;
    t9 += v * b7;
    t10 += v * b8;
    t11 += v * b9;
    t12 += v * b10;
    t13 += v * b11;
    t14 += v * b12;
    t15 += v * b13;
    t16 += v * b14;
    t17 += v * b15;
    v = a[3];
    t3 += v * b0;
    t4 += v * b1;
    t5 += v * b2;
    t6 += v * b3;
    t7 += v * b4;
    t8 += v * b5;
    t9 += v * b6;
    t10 += v * b7;
    t11 += v * b8;
    t12 += v * b9;
    t13 += v * b10;
    t14 += v * b11;
    t15 += v * b12;
    t16 += v * b13;
    t17 += v * b14;
    t18 += v * b15;
    v = a[4];
    t4 += v * b0;
    t5 += v * b1;
    t6 += v * b2;
    t7 += v * b3;
    t8 += v * b4;
    t9 += v * b5;
    t10 += v * b6;
    t11 += v * b7;
    t12 += v * b8;
    t13 += v * b9;
    t14 += v * b10;
    t15 += v * b11;
    t16 += v * b12;
    t17 += v * b13;
    t18 += v * b14;
    t19 += v * b15;
    v = a[5];
    t5 += v * b0;
    t6 += v * b1;
    t7 += v * b2;
    t8 += v * b3;
    t9 += v * b4;
    t10 += v * b5;
    t11 += v * b6;
    t12 += v * b7;
    t13 += v * b8;
    t14 += v * b9;
    t15 += v * b10;
    t16 += v * b11;
    t17 += v * b12;
    t18 += v * b13;
    t19 += v * b14;
    t20 += v * b15;
    v = a[6];
    t6 += v * b0;
    t7 += v * b1;
    t8 += v * b2;
    t9 += v * b3;
    t10 += v * b4;
    t11 += v * b5;
    t12 += v * b6;
    t13 += v * b7;
    t14 += v * b8;
    t15 += v * b9;
    t16 += v * b10;
    t17 += v * b11;
    t18 += v * b12;
    t19 += v * b13;
    t20 += v * b14;
    t21 += v * b15;
    v = a[7];
    t7 += v * b0;
    t8 += v * b1;
    t9 += v * b2;
    t10 += v * b3;
    t11 += v * b4;
    t12 += v * b5;
    t13 += v * b6;
    t14 += v * b7;
    t15 += v * b8;
    t16 += v * b9;
    t17 += v * b10;
    t18 += v * b11;
    t19 += v * b12;
    t20 += v * b13;
    t21 += v * b14;
    t22 += v * b15;
    v = a[8];
    t8 += v * b0;
    t9 += v * b1;
    t10 += v * b2;
    t11 += v * b3;
    t12 += v * b4;
    t13 += v * b5;
    t14 += v * b6;
    t15 += v * b7;
    t16 += v * b8;
    t17 += v * b9;
    t18 += v * b10;
    t19 += v * b11;
    t20 += v * b12;
    t21 += v * b13;
    t22 += v * b14;
    t23 += v * b15;
    v = a[9];
    t9 += v * b0;
    t10 += v * b1;
    t11 += v * b2;
    t12 += v * b3;
    t13 += v * b4;
    t14 += v * b5;
    t15 += v * b6;
    t16 += v * b7;
    t17 += v * b8;
    t18 += v * b9;
    t19 += v * b10;
    t20 += v * b11;
    t21 += v * b12;
    t22 += v * b13;
    t23 += v * b14;
    t24 += v * b15;
    v = a[10];
    t10 += v * b0;
    t11 += v * b1;
    t12 += v * b2;
    t13 += v * b3;
    t14 += v * b4;
    t15 += v * b5;
    t16 += v * b6;
    t17 += v * b7;
    t18 += v * b8;
    t19 += v * b9;
    t20 += v * b10;
    t21 += v * b11;
    t22 += v * b12;
    t23 += v * b13;
    t24 += v * b14;
    t25 += v * b15;
    v = a[11];
    t11 += v * b0;
    t12 += v * b1;
    t13 += v * b2;
    t14 += v * b3;
    t15 += v * b4;
    t16 += v * b5;
    t17 += v * b6;
    t18 += v * b7;
    t19 += v * b8;
    t20 += v * b9;
    t21 += v * b10;
    t22 += v * b11;
    t23 += v * b12;
    t24 += v * b13;
    t25 += v * b14;
    t26 += v * b15;
    v = a[12];
    t12 += v * b0;
    t13 += v * b1;
    t14 += v * b2;
    t15 += v * b3;
    t16 += v * b4;
    t17 += v * b5;
    t18 += v * b6;
    t19 += v * b7;
    t20 += v * b8;
    t21 += v * b9;
    t22 += v * b10;
    t23 += v * b11;
    t24 += v * b12;
    t25 += v * b13;
    t26 += v * b14;
    t27 += v * b15;
    v = a[13];
    t13 += v * b0;
    t14 += v * b1;
    t15 += v * b2;
    t16 += v * b3;
    t17 += v * b4;
    t18 += v * b5;
    t19 += v * b6;
    t20 += v * b7;
    t21 += v * b8;
    t22 += v * b9;
    t23 += v * b10;
    t24 += v * b11;
    t25 += v * b12;
    t26 += v * b13;
    t27 += v * b14;
    t28 += v * b15;
    v = a[14];
    t14 += v * b0;
    t15 += v * b1;
    t16 += v * b2;
    t17 += v * b3;
    t18 += v * b4;
    t19 += v * b5;
    t20 += v * b6;
    t21 += v * b7;
    t22 += v * b8;
    t23 += v * b9;
    t24 += v * b10;
    t25 += v * b11;
    t26 += v * b12;
    t27 += v * b13;
    t28 += v * b14;
    t29 += v * b15;
    v = a[15];
    t15 += v * b0;
    t16 += v * b1;
    t17 += v * b2;
    t18 += v * b3;
    t19 += v * b4;
    t20 += v * b5;
    t21 += v * b6;
    t22 += v * b7;
    t23 += v * b8;
    t24 += v * b9;
    t25 += v * b10;
    t26 += v * b11;
    t27 += v * b12;
    t28 += v * b13;
    t29 += v * b14;
    t30 += v * b15;

    t0 += 38 * t16;
    t1 += 38 * t17;
    t2 += 38 * t18;
    t3 += 38 * t19;
    t4 += 38 * t20;
    t5 += 38 * t21;
    t6 += 38 * t22;
    t7 += 38 * t23;
    t8 += 38 * t24;
    t9 += 38 * t25;
    t10 += 38 * t26;
    t11 += 38 * t27;
    t12 += 38 * t28;
    t13 += 38 * t29;
    t14 += 38 * t30;

    var c = 1;
    v = t0 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t0 = v - c * 0x10000;
    v = t1 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t1 = v - c * 0x10000;
    v = t2 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t2 = v - c * 0x10000;
    v = t3 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t3 = v - c * 0x10000;
    v = t4 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t4 = v - c * 0x10000;
    v = t5 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t5 = v - c * 0x10000;
    v = t6 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t6 = v - c * 0x10000;
    v = t7 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t7 = v - c * 0x10000;
    v = t8 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t8 = v - c * 0x10000;
    v = t9 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t9 = v - c * 0x10000;
    v = t10 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t10 = v - c * 0x10000;
    v = t11 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t11 = v - c * 0x10000;
    v = t12 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t12 = v - c * 0x10000;
    v = t13 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t13 = v - c * 0x10000;
    v = t14 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t14 = v - c * 0x10000;
    v = t15 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t15 = v - c * 0x10000;
    t0 += c - 1 + 37 * (c - 1);

    c = 1;
    v = t0 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t0 = v - c * 0x10000;
    v = t1 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t1 = v - c * 0x10000;
    v = t2 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t2 = v - c * 0x10000;
    v = t3 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t3 = v - c * 0x10000;
    v = t4 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t4 = v - c * 0x10000;
    v = t5 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t5 = v - c * 0x10000;
    v = t6 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t6 = v - c * 0x10000;
    v = t7 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t7 = v - c * 0x10000;
    v = t8 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t8 = v - c * 0x10000;
    v = t9 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t9 = v - c * 0x10000;
    v = t10 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t10 = v - c * 0x10000;
    v = t11 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t11 = v - c * 0x10000;
    v = t12 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t12 = v - c * 0x10000;
    v = t13 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t13 = v - c * 0x10000;
    v = t14 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t14 = v - c * 0x10000;
    v = t15 + c + 0xFFFF;
    c = v ~/ 0x10000;
    t15 = v - c * 0x10000;
    t0 += c - 1 + 37 * (c - 1);

    result[0] = t0;
    result[1] = t1;
    result[2] = t2;
    result[3] = t3;
    result[4] = t4;
    result[5] = t5;
    result[6] = t6;
    result[7] = t7;
    result[8] = t8;
    result[9] = t9;
    result[10] = t10;
    result[11] = t11;
    result[12] = t12;
    result[13] = t13;
    result[14] = t14;
    result[15] = t15;
  }
}
