import 'package:starknet/starknet.dart';

import '../transfer_erc20.dart';
import '../config.dart';

void main() async {

  final provider = JsonRpcProvider(nodeUri: infurasepoliaTestnetUri);
  final chainId = StarknetChainId.testNet;


  final raw = "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"starknet_addInvokeTransaction\",\"params\":[{\"type\":\"INVOKE\",\"sender_address\":\"0x5fa913876f18233c2cfb0450f0ed1c7eb3a25daee1fe073dec8ea28666449e8\",\"calldata\":[\"0x1\",\"0x4718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d\",\"0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e\",\"0x3\",\"0x415924ae6ef708be45f19310d16aba28b4b3500425773d6e80ab61c74d07f1e\",\"0x318\",\"0x0\"],\"version\":\"0x3\",\"signature\":[\"0x23fb6569d6b08c719189eab2376bb7cf118e0edfa928d30c327a39c923863c4\",\"0x320358ddbc05936dc7ba12d219bfe8e2341bd3b5923c4ee811a2c9a40fb72cb\"],\"nonce\":\"0xd\",\"resource_bounds\":{\"l1_gas\":{\"max_amount\":\"0x25\",\"max_price_per_unit\":\"0x125c2dd40eed\"},\"l2_gas\":{\"max_amount\":\"0x0\",\"max_price_per_unit\":\"0x0\"}},\"tip\":\"0x0\",\"paymaster_data\":[],\"account_deployment_data\":[],\"nonce_data_availability_mode\":\"L1\",\"fee_data_availability_mode\":\"L1\"}]}";
  provider.sendRawTx(raw);

  // final account = Account.fromMnemonic(
  //   mnemonic: testMnemonic,
  //   provider: provider,
  //   chainId: chainId,
  //   index: 0,
  // );
  // final receiverAddress = Felt.fromHexString(
  //     "0x03f0bdad05d78b1136ad2c6f37142e5c8c78b7022baa93dcbb008b27840a88bb");
  // /// 签名并发送
  //
  // final nonce = await account.getNonce();
  // final functionCall = FunctionCall(
  //     contractAddress: ethAddress,
  //     entryPointSelector: getSelectorByName("transfer"),
  //     calldata: [
  //       // version
  //       Felt.fromHexString('0x1'),
  //       // eth 代币 合约地址
  //       ethAddress,
  //       // selector name transfer 16 进制
  //       transferSelector,
  //       // 未知， 默认3
  //       Felt.fromHexString('0x3'),
  //       // 接受方地址
  //       receiverAddress,
  //       // amount low
  //       Felt.fromInt(1000),
  //       // amount high
  //       Felt.fromInt(0),
  //     ]);
  //
  // final fee = await account.getEstimateMaxFeeForBraavosInvokeTx(
  //   nonce: nonce,
  //   functionCalls: [functionCall],
  // );
  // final tx = await account.send(
  //   recipient: receiverAddress,
  //   amount: Uint256(
  //     low: Felt.fromInt(1000000000000000),
  //     high: Felt.fromInt(0),
  //   ),
  //   // maxFee: Felt.fromHexString("0x28fd0548848"),
  //   erc20ContractAddress: ethAddress,
  //   maxFee: fee,
  // );
  // print("tx = ${tx}");





  /// 仅签名
  // final signed = await account.transferSign(
  //   recipient: receiverAddress,
  //   amount: Uint256(
  //     low: Felt.fromInt(001000000000000000),
  //     high: Felt.fromInt(0),
  //   ),
  //   // maxFee: Felt.fromHexString("0x28fd0548848"),
  //   erc20ContractAddress: ethAddress,
  // );
  //
  //
  // print("signed = ${signed.toJson()}");
}
