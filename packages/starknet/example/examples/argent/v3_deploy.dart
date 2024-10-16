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
      index: 5,
      accountDerivation:
          ArgentXAccountDerivation(provider: provider, chainId: chainId));

  final valid = await account.isValid;
  if (valid) {
    print("账户已经部署: ${account.accountAddress.toHexAddressString()}");
    return;
  } else {
    print("账户未部署: ${account.accountAddress.toHexAddressString()}");
  }
  // return;
  final fee = await account.getEstimateMaxFeeForArgentDeployAccountV3Tx(
    address: account.accountAddress,
    nonce: Felt.fromInt(0),
    constructorCalldata: [
      Felt.fromInt(0),
      account.signer.publicKey,
      Felt.fromInt(1)
    ],
    contractAddressSalt: account.signer.publicKey,
    classHash: ArgentXAccountDerivation.classHash,
    feeMultiplier: 1.5,
  );

  print("账户部署手续费gas: ${fee.gas.toBigInt()}");
  print("账户部署手续费gasPrice: ${fee.gasPrice.toBigInt()}");
  print("账户部署手续费 STRK: ${fee.overallFee.toBigInt()}");

  // return;
  final argentAccountDerivation =
      ArgentXAccountDerivation(provider: provider, chainId: chainId);
  final txHash = await argentAccountDerivation.deploy(
    account: account,
    gasPrice: fee.gasPrice,
    gas: fee.gas,
    version: '0x3',
  );
  print("tx hash: ${json.encode(txHash.toJson())}");

  // final signed =
  //     await argentAccountDerivation.deploySigned(account: account, maxFee: fee);
  // print("signed: $signed");
}
