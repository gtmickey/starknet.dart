import 'dart:convert';

import 'package:starknet/starknet.dart';

import 'config.dart';

void main() async {

  final provider = JsonRpcProvider(nodeUri: infurasepoliaTestnetUri);
  final chainId = StarknetChainId.testNet;

  final account = Account.fromMnemonic(
    mnemonic: testMnemonic.split(" "),
    provider: provider,
    chainId: chainId,
    index: 4,
  );

  final valid = await account.isValid;
  if (valid) {
    print("account already deploy");
    return;
  }
  print("address = ${account.accountAddress.toJson()}");
  final braavosAccount =
      BraavosAccountDerivation(provider: provider, chainId: chainId);

  // final deployTxHash = await braavosAccount.deploy(account: account);
  // print("deployTxHash: ${deployTxHash.toHexString()}");

  final signed = await braavosAccount.deploySigned(account: account);
  print("signed: ${json.encode(signed.toJson())}");
}
