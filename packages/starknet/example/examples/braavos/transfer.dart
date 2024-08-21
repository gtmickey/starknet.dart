import 'package:starknet/starknet.dart';

import '../transfer_erc20.dart';
import 'config.dart';

void main() async {

  final provider = JsonRpcProvider(nodeUri: infurasepoliaTestnetUri);
  final chainId = StarknetChainId.testNet;

  final account = Account.fromMnemonic(
    mnemonic: testMnemonic.split(" "),
    provider: provider,
    chainId: chainId,
    index: 0,
  );
  final receiverAddress = Felt.fromHexString(
      "0x0261b745499c44af9e29138525025e988ad1d90d6d53cf0d2f91510073283bb5");
  final tx = await account.send(
    recipient: receiverAddress,
    amount: Uint256(
      low: Felt.fromInt(123455),
      high: Felt.fromInt(0),
    ),
    // maxFee: Felt.fromHexString("0x28fd0548848"),
    erc20ContractAddress: strkAddress,
  );

  print("transfer hash = $tx");
}
