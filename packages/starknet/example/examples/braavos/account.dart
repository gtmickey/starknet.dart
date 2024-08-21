import 'package:starknet/starknet.dart';

import 'config.dart';

Future<void> printAccountInfo(AccountInfo account) async {
  print("Address: ${account.address.toJson()}");
  print("Public key: ${account.publicKey.toJson()}");
  print("Private key: ${account.privateKey.toJson()}");
  print("----------------------");
}

void main() async {
  final chain = getExtendedPrivateKey(testMnemonic);

  final accountInfo0 = BraavosAccountDerivation.getAccountInfoFromMnemonic(
    testMnemonic,
    0,
  );
  final accountInfo1 = BraavosAccountDerivation.getAccountInfoFromMnemonic(
    testMnemonic,
    1,
  );
  final accountInfo2 = BraavosAccountDerivation.getAccountInfoFromMnemonic(
    testMnemonic,
    3,
  );
  // 从扩展私钥生成的账户
  final accountInfo11 =
      BraavosAccountDerivation.getAccountInfoFromExtendedPrivateKey(
    chain["chainKey"]!,
    chain["chainCode"]!,
    1,
  );

  printAccountInfo(accountInfo0);
  printAccountInfo(accountInfo1);
  printAccountInfo(accountInfo2);
  printAccountInfo(accountInfo11);
}
