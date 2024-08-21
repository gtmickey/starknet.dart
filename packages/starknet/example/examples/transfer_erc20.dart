import 'package:starknet/starknet.dart';

final privateKey = Felt.fromHexString(
    "0x2d4b135bb1bab564821180b31651828bd09d1d33e749fbb97f647bd1eca04df");

final accountAddress = Felt.fromHexString(
    "0x6c2a560e3a2a1303699e24a6a9249ecb6e9a51163dada01b2ab0b8a43e24905");

final ethAddress = Felt.fromHexString(
    "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7");

final strkAddress = Felt.fromHexString(
    "0x4718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d");

final receiverAddress = Felt.fromHexString(
    "0x0261b745499c44af9e29138525025e988ad1d90d6d53cf0d2f91510073283bb5");

void main() async {
  final provider = JsonRpcProvider(nodeUri: infurasepoliaTestnetUri);
  final chainId = Felt.fromHexString("0x534e5f5345504f4c4941");
  final signer = Signer(privateKey: privateKey);
  final account = Account(
    provider: provider,
    signer: signer,
    accountAddress: accountAddress,
    chainId: chainId,
  );
  final nonce = await account.getNonce(BlockId.latest);
  print("wtf nonce $nonce");

  final functionCall = FunctionCall(
      contractAddress: ethAddress,
      entryPointSelector: getSelectorByName("transfer"),
      calldata: [
        Felt.fromHexString('0x1'),
        Felt.fromHexString(
            '0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7'),
        Felt.fromHexString(
            '0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e'),
        Felt.fromHexString('0x3'),
        receiverAddress,
        Felt.fromHexString('0x64'),
        Felt.fromHexString('0x0'),
      ]);

  final invokeFee = await account.getEstimateMaxFeeForInvokeTx(
      functionCalls: [functionCall], nonce: nonce);

  print("wtf1 ${invokeFee.toHexString()}");

//   final s = account.signer.signInvokeTransactionsV1(
//     transactions: [functionCall],
//     senderAddress: accountAddress,
//     chainId: chainId,
//     nonce: nonce,
//   );
//   final invokeV1 = BroadcastedInvokeTxnV1(
//     type: 'INVOKE',
//     maxFee: Felt.fromInt(0),
//     version: '1',
//     signature: [s.first, s.last],
//     nonce: nonce,
//     senderAddress: accountAddress,
//     calldata: [receiverAddress, Felt.fromInt(1)],
//   );
// //
//   EstimateFeeRequest estimateFeeRequest = EstimateFeeRequest(
//     request: [invokeV1],
//     blockId: BlockId.latest,
//     simulation_flags: [],
//   );
// //
//   final estimateFeeResponse = await provider.estimateFee(estimateFeeRequest);
// //
//   print('wtf $estimateFeeResponse');
  // final response = await account.execute(functionCalls: [
  //   FunctionCall(
  //       contractAddress: ethAddress,
  //       entryPointSelector: getSelectorByName("transfer"),
  //       calldata: [receiverAddress, Felt.fromInt(1)])
  // ], maxFee: Felt.fromInt(16000000000001), nonce: nonce);
  //
  // print(response);
}
