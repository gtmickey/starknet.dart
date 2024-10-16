import 'package:starknet/starknet.dart';

import '../config.dart';

Future<void> printAccountInfo(AccountInfo account) async {
  print("Address: ${account.address.toJson()}");
  print("Public key: ${account.publicKey.toJson()}");
  print("Private key: ${account.privateKey.toJson()}");
  print("----------------------");
}

/// 账户创建例子
void main() async {
  /// 默认获取第0个账户
  final accountInfo0 = ArgentXAccountDerivation.getAccountInfoFromMnemonic(
    testMnemonic,
  );
  print("默认获取第0个账户");
  printAccountInfo(accountInfo0);

  /// 通过助记词获取第1个账户
  final accountInfo1 = ArgentXAccountDerivation.getAccountInfoFromMnemonic(
    testMnemonic,
    index: 1,
  );
  print("通过助记词获取第1个账户");
  printAccountInfo(accountInfo1);

  /// 通过私钥直接生成账户
  final accountInfo0ByPrivateKey =
      ArgentXAccountDerivation.getAccountInfoFromPrivateKey(
          bigIntToBytes(accountInfo0.privateKey.toBigInt()));
  print("通过私钥直接生成账户0");
  printAccountInfo(accountInfo0ByPrivateKey);

  /// 通过扩展私钥生成的账户
  final extendedPrivateKey =
      ArgentXAccountDerivation.getExtendedPrivateKey(testMnemonic);

  final accountInfo1ByExtendedPrivateKey =
      ArgentXAccountDerivation.getAccountInfoFromExtendedPrivateKey(
    extendedPrivateKey["key"]!,
    extendedPrivateKey["chainCode"]!,
    6,
  );
  print("通过扩展私钥生成的账户1");
  printAccountInfo(accountInfo1ByExtendedPrivateKey);

  print("wtf chain id = ${Felt.fromString('SN_SEPOLIA').toHexString()}");
}
