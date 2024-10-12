import 'package:starknet/starknet.dart';

import '../transfer_erc20.dart';
import '../config.dart';

void main() async {
  final provider = JsonRpcProvider(nodeUri: infurasepoliaTestnetUri);
  final chainId = StarknetChainId.testNet;

  final account = Account.fromMnemonic(
    mnemonic: testMnemonic,
    provider: provider,
    chainId: chainId,
    index: 0,
    accountDerivation:
        ArgentXAccountDerivation(provider: provider, chainId: chainId),
  );
  final receiverAddress = Felt.fromHexString(
      "0x03f0bdad05d78b1136ad2c6f37142e5c8c78b7022baa93dcbb008b27840a88bb");

  /// 签名并发送
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
        Felt.fromInt(12344),
        // amount high
        Felt.fromInt(0),
      ]);

  final fee = await account.getEstimateMaxFeeForArgentInvokeTx(
    nonce: nonce,
    functionCalls: [functionCall],
    version: '0x1'
  );
  print("wtf fee $fee");
  final tx = await account.send(
    recipient: receiverAddress,
    amount: Uint256(
      low: Felt.fromInt(222344),
      high: Felt.fromInt(0),
    ),
    maxFee: fee,
    erc20ContractAddress: ethAddress,
  );
  print("tx = ${tx}");

  /// 仅签名
  // final signed = await account.transferSign(
  //   recipient: receiverAddress,
  //   amount: Uint256(
  //     low: Felt.fromInt(1000000000000000),
  //     high: Felt.fromInt(0),
  //   ),
  //   // maxFee: Felt.fromHexString("0x28fd0548848"),
  //   erc20ContractAddress: ethAddress,
  //   maxFee: fee,
  // );
  //
  //
  // print("signed = $signed");
}
