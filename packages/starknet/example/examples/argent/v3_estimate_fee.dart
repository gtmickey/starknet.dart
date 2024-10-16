import 'package:starknet/src/crypto/poseidon.dart';
import 'package:starknet/starknet.dart';

import '../config.dart';
import '../transfer_erc20.dart';

void main() async {
  final provider = JsonRpcProvider(nodeUri: infurasepoliaTestnetUri);
  final chainId = StarknetChainId.testNet;

  void deployFee() async {
    final account = Account.fromMnemonic(
        mnemonic: testMnemonic,
        provider: provider,
        chainId: chainId,
        index: 7,
        accountDerivation:
            ArgentXAccountDerivation(provider: provider, chainId: chainId));

    late Felt nonce;
    try {
      nonce = await account.getNonce();
    } catch (_) {
      nonce = Felt.fromInt(0);
    }

    print("wtf account address = ${account.accountAddress.toHexString()}");
    print("wtf account pri = ${account.signer.privateKey.toHexString()}");
    final fee = await account.getEstimateMaxFeeForArgentDeployAccountV3Tx(
      address: account.accountAddress,
      nonce: nonce,
      constructorCalldata: [
        Felt.fromInt(0),
        account.signer.publicKey,
        Felt.fromInt(1)
      ],
      contractAddressSalt: account.signer.publicKey,
      classHash: ArgentXAccountDerivation.classHash,
      feeMultiplier: 1.5,
    );

    print("deploy fee * 1.5 = ${fee.gas.toBigInt()}");
    print("deploy fee * 1.5 = ${fee.gasPrice.toBigInt()}");
    print("deploy fee * 1.5 = ${fee.overallFee.toBigInt()}");
  }

  deployFee();

  void transferFee() async {
    final account = Account.fromMnemonic(
      mnemonic: testMnemonic,
      provider: provider,
      chainId: chainId,
      index: 1,
      accountDerivation:
          ArgentXAccountDerivation(provider: provider, chainId: chainId),
    );

    print("wtf privatekey = ${account.signer.privateKey.toHexString()}");
    print("wtf address = ${account.accountAddress.toHexString()}");

    final receiverAddress = Felt.fromHexString(
        "0x06c2a560e3a2a1303699e24a6a9249ecb6e9a51163dada01b2ab0b8a43e24905");
    final nonce = await account.getNonce();
    print("wtf nonce $nonce");

    final functionCall = FunctionCall(
        contractAddress: strkContractAddress,
        entryPointSelector: getSelectorByName("transfer"),
        calldata: [
          // 接受方地址
          receiverAddress,
          // amount low
          Felt.fromInt(1000),
          // amount high
          Felt.fromInt(0),
        ]);

    final feeV3 = await account.getEstimateMaxFeeForArgentInvokeTxV3(
      nonce: nonce,
      functionCalls: [functionCall],
      gasPrice: Felt.fromInt(0),
      gas: Felt.fromInt(0),
      feeMultiplier: 1.5,
      blockId: BlockId.latest,
      classHash: ArgentXAccountDerivation.classHash,
      contractAddressSalt: account.signer.publicKey,
    );
    print("transfer fee * 1.5 = ${feeV3.toString()}");
  }

  // transferFee();
}
