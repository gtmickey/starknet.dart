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
          ArgentXAccountDerivation(provider: provider, chainId: chainId));

  final valid = await account.isValid;
  if (valid) {
    print("account already deploy");
    return;
  }

  final fee = await account.getEstimateMaxFeeForArgentDeployAccountTx(
    nonce: Felt.fromInt(0),
    constructorCalldata: [
      Felt.fromInt(0),
      account.signer.publicKey,
      Felt.fromInt(1)
    ],
    contractAddressSalt: account.signer.publicKey,
    classHash: ArgentXAccountDerivation.classHash,
    version: "0x100000000000000000000000000000001",
  );
  print("address = ${account.accountAddress.toJson()}");
  final argentAccountDerivation =
      ArgentXAccountDerivation(provider: provider, chainId: chainId);

  final txHash =
      await argentAccountDerivation.deploy(account: account, maxFee: fee);
  print("tx hash: ${json.encode(txHash.toJson())}");

  final signed =
      await argentAccountDerivation.deploySigned(account: account, maxFee: fee);
  print("signed: $signed");
}
