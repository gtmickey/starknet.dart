import 'package:starknet/starknet.dart';

import 'config.dart';

void main() async {

  final provider = JsonRpcProvider(nodeUri: infurasepoliaTestnetUri);
  final chainId = StarknetChainId.testNet;

  void deployFee() async {
    final account = Account.fromMnemonic(
      mnemonic: testMnemonic.split(" "),
      provider: provider,
      chainId: chainId,
      index: 4,
    );

    late Felt nonce;
    try {
      nonce = await account.getNonce();
    } catch (_) {
      nonce = Felt.fromInt(0);
    }
    final fee = await account.getEstimateMaxFeeForBraavosDeployAccountTx(
      nonce: nonce,
      constructorCalldata: [account.signer.publicKey],
      contractAddressSalt: account.signer.publicKey,
      classHash: BraavosAccountDerivation.classHash,
      baseClassHash: BraavosAccountDerivation.baseClassHash,
    );

    print("deploy fee * 1.2 = ${fee.toBigInt()}");
  }
  deployFee();

  void transferFee() async {
    final account = Account.fromMnemonic(
      mnemonic: testMnemonic.split(" "),
      provider: provider,
      chainId: chainId,
      index: 1,
    );


    print("wtf privatekey = ${account.signer.privateKey.toHexString()}");
    final nonce = await account.getNonce();
    final receiverAddress = Felt.fromHexString(
        "0x0261b745499c44af9e29138525025e988ad1d90d6d53cf0d2f91510073283bb5");
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
          Felt.fromHexString(
              '0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e'),
          // 未知， 默认3
          Felt.fromHexString('0x3'),
          // 接受方地址
          receiverAddress,
          // amount low
          Felt.fromInt(1000),
          // amount high
          Felt.fromInt(0),

        ]);

    final fee = await account.getEstimateMaxFeeForBraavosInvokeTx(
      nonce: nonce,
      functionCalls: [functionCall],
    );

    print("transfer fee * 1.2 = ${fee.toBigInt()}");
  }

  transferFee();

  // void transferFee() async {
  //   final account = Account.fromMnemonic(
  //     mnemonic: mnemonic.split(" "),
  //     provider: provider,
  //     chainId: chainId,
  //     index: 0,
  //   );
  //   final recipient = Felt.fromHexString(
  //       "0x003b10442d23189b30acf06fc16d8140b133f1ce9ae3c4810e52c144f0489072");
  //   final txHash = await account.send(
  //     recipient: recipient,
  //     amount: Uint256(
  //       low: Felt.fromInt(1234000),
  //       high: Felt.fromInt(0),
  //     ),
  //   );
  //
  //   print("txHash = $txHash");
  // }
  // transferFee();
}
