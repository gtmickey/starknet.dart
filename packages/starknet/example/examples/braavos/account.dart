import 'package:starknet/starknet.dart';

import '../config.dart';

Future<void> printAccountInfo(AccountInfo account) async {
  print("Address: ${account.address.toJson()}");
  print("Public key: ${account.publicKey.toJson()}");
  print("Private key: ${account.privateKey.toJson()}");
  print("----------------------");
}
    // ./target/debug/starkli account braavos init a5 --private-key=0x051a76c2380baf3e57f1dc7dc0a39a683d5e325acb8f2976536f41ffefe67a22
// ./target/debug/starkli account deploy a5 --private-key=0x051a76c2380baf3e57f1dc7dc0a39a683d5e325acb8f2976536f41ffefe67a22 --estimate-only
void main() async {

  print(" aa = ${Felt.fromString("STARKNET_CONTRACT_ADDRESS").toHexString()}");

  final chain = BraavosAccountDerivation.getExtendedPrivateKey(testMnemonic);

  final accountInfo0 = BraavosAccountDerivation.getAccountInfoFromMnemonic(
    testMnemonic,
    5,
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
