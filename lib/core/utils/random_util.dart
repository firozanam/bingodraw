import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class RandomUtil {
  static final Random _random = Random.secure();

  /// Generates a cryptographically secure random number within a range
  static int secureRandom(int max) {
    final Uint8List randomBytes = Uint8List(32);
    for (var i = 0; i < randomBytes.length; i++) {
      randomBytes[i] = _random.nextInt(256);
    }

    final hash = sha256.convert(randomBytes);
    final bigInt = BigInt.parse(hash.toString(), radix: 16);
    return (bigInt % BigInt.from(max)).toInt();
  }

  /// Generates a verifiable random hash using block data
  static String generateVerifiableHash(
    int blockNumber,
    String blockHash,
    int timestamp,
  ) {
    final input = '$blockNumber:$blockHash:$timestamp';
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// Selects a winner using verifiable random function
  static int selectWinner(
    int participantCount,
    String verifiableHash,
  ) {
    final hashBytes = Uint8List.fromList(hex.decode(verifiableHash));
    final hashInt = BigInt.parse(hex.encode(hashBytes), radix: 16);
    return (hashInt % BigInt.from(participantCount)).toInt();
  }
}