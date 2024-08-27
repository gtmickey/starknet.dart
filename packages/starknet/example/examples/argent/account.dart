import 'package:starknet/starknet.dart';

import '../config.dart';


Future<void> printAccountInfo(AccountInfo account) async {
  print("Address: ${account.address.toJson()}");
  print("Public key: ${account.publicKey.toJson()}");
  print("Private key: ${account.privateKey.toJson()}");
  print("----------------------");
}

void main() async {

  final chain = ArgentXAccountDerivation.getExtendedPrivateKey(testMnemonic);

  final accountInfo0 = ArgentXAccountDerivation.getAccountInfoFromMnemonic(
    testMnemonic,
    3,
  );
  // final accountInfo1 = ArgentXAccountDerivation.getAccountInfoFromMnemonic(
  //   testMnemonic,
  //   1,
  // );
  // final accountInfo2 = ArgentXAccountDerivation.getAccountInfoFromMnemonic(
  //   testMnemonic,
  //   2,
  // );
  // 从扩展私钥生成的账户
  // final accountInfo11 =
  // ArgentXAccountDerivation.getAccountInfoFromExtendedPrivateKey(
  //   chain["chainKey"]!,
  //   chain["chainCode"]!,
  //   1,
  // );

  printAccountInfo(accountInfo0);
  // printAccountInfo(accountInfo1);
  // printAccountInfo(accountInfo2);
  // printAccountInfo(accountInfo11);
}
