import 'dart:convert';

import 'package:starknet/starknet.dart';

import '../config.dart';

void main() async {

  final provider = JsonRpcProvider(nodeUri: infurasepoliaTestnetUri);
  final chainId = StarknetChainId.testNet;

  final account = Account.fromMnemonic(
    mnemonic: testMnemonic,
    provider: provider,
    chainId: chainId,
    index: 3,
      accountDerivation:
      ArgentXAccountDerivation(provider: provider, chainId: chainId)
  );

  final valid = await account.isValid;
  if (valid) {
    print("account already deploy");
    return;
  }
  print("address = ${account.accountAddress.toJson()}");
  final argentAccountDerivation =
      ArgentXAccountDerivation(provider: provider, chainId: chainId);


  final txHash = await argentAccountDerivation.deploy(account: account);
  print("tx hash: ${json.encode(txHash.toJson())}");
}
