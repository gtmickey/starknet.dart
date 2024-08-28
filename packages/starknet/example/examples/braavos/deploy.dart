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
    index: 4,
  );

  final valid = await account.isValid;
  if (valid) {
    print("account already deploy");
    return;
  }
  final fee = await account.getEstimateMaxFeeForBraavosDeployAccountTx(
    nonce: Felt.fromInt(0),
    constructorCalldata: [account.signer.publicKey],
    contractAddressSalt: account.signer.publicKey,
    classHash: BraavosAccountDerivation.classHash,
    baseClassHash: BraavosAccountDerivation.baseClassHash,
    version: "0x1",
  );
  print("address = ${account.accountAddress.toJson()}");
  final braavosAccount =
      BraavosAccountDerivation(provider: provider, chainId: chainId);

  // final deployTxHash = await braavosAccount.deploy(account: account, maxFee: fee);
  // print("deployTxHash: ${deployTxHash.toHexString()}");

  final signed = await braavosAccount.deploySigned(
    account: account,
    maxFee: fee,
  );
  print("signed: $signed");
}
