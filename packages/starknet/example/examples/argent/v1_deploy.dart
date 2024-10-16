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
      index: 7,
      accountDerivation:
          ArgentXAccountDerivation(provider: provider, chainId: chainId));

  final valid = await account.isValid;
  if (valid) {
    print("账户已经部署 ${account.accountAddress.toHexString()}");
    return;
  } else {
    print("账户${account.accountAddress.toHexString()}未部署");

  }
  // return;
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
    feeMultiplier: 1.0,
  );
  print("账户部署手续费 ETH: ${fee.toBigInt()}");
  // return;
  final argentAccountDerivation =
      ArgentXAccountDerivation(provider: provider, chainId: chainId);

  final txHash =
      await argentAccountDerivation.deploy(account: account, maxFee: fee,version: "0x1");
  print("tx hash: ${json.encode(txHash.toJson())}");

  final signed =
      await argentAccountDerivation.deploySigned(account: account, maxFee: fee);
  print("signed: $signed");
}
