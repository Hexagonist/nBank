import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> generateValidUniqueNRB() async {
  final firestore = FirebaseFirestore.instance;
  final random = Random();

  const String bankIdentifier = '10501110'; 

 
  String calculateChecksum(String accountBody) {
    final rearranged = accountBody + '252100'; 
    final number = BigInt.parse(rearranged);
    final checksum = 98 - (number % BigInt.from(97)).toInt();
    return checksum.toString().padLeft(2, '0');
  }

  while (true) {
    String userPart = List.generate(16, (_) => random.nextInt(10)).join();

    String accountBody = bankIdentifier + userPart;

    String checksum = calculateChecksum(accountBody);

    String nrb = checksum + accountBody;

    final existing = await firestore
        .collection('users')
        .where('accountNumber', isEqualTo: nrb)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) return nrb;
  }
}
