import 'package:starknet/starknet.dart';

import '../config.dart';

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
    final fee = await account.getEstimateMaxFeeForArgentDeployAccountTx(
      nonce: nonce,
      constructorCalldata: [
        Felt.fromInt(0),
        account.signer.publicKey,
        Felt.fromInt(1)
      ],
      contractAddressSalt: account.signer.publicKey,
      classHash: ArgentXAccountDerivation.classHash,
      version: "0x100000000000000000000000000000001",
      feeMultiplier: 1.5
    );

    print("deploy fee * 1.5 = ${fee.toBigInt()}");
  }

  deployFee();

  void transferFee() async {
    final account = Account.fromMnemonic(
      mnemonic: testMnemonic,
      provider: provider,
      chainId: chainId,
      index: 0,
      accountDerivation:
          ArgentXAccountDerivation(provider: provider, chainId: chainId),
    );

    print("wtf privatekey = ${account.signer.privateKey.toHexString()}");

    final receiverAddress = Felt.fromHexString(
        "0x0261b745499c44af9e29138525025e988ad1d90d6d53cf0d2f91510073283bb5");
    final nonce = await account.getNonce();
    print("wtf nonce $nonce");

    final functionCall = FunctionCall(
        contractAddress: ethAddress,
        entryPointSelector: getSelectorByName("transfer"),
        calldata: [
          // version
          Felt.fromHexString('0x1'),
          // eth 代币 合约地址
          ethAddress,
          // selector name transfer 16 进制
          transferSelector,
          // 未知， 默认3
          Felt.fromHexString('0x3'),
          // 接受方地址
          receiverAddress,
          // amount low
          Felt.fromInt(1000),
          // amount high
          Felt.fromInt(0),
        ]);

    final fee = await account.getEstimateMaxFeeForArgentInvokeTx(
      nonce: nonce,
      functionCalls: [functionCall],
      version: '0x1'
    );

    print("transfer fee * 1.2 = ${fee.toBigInt()}");
  }

  // transferFee();
}
