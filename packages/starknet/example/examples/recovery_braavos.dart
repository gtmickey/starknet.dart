import 'package:starknet/starknet.dart';

import 'deploy_openzeppelin.dart';

// test random mnemonic
final mnemonic =
    "fiscal document grain ecology wheat around sport nice guitar topple add north"
        .split(" ");

void main() async {
  final provider = JsonRpcProvider(nodeUri: infurasepoliaTestnetUri);
  final chainId = StarknetChainId.testNet;
  print("Retrieving Braavos accounts");
  bool valid = true;
  while (valid) {
    print("########################");
    final account = Account.fromMnemonic(
      mnemonic: mnemonic,
      provider: provider,
      chainId: Felt.fromHexString("0x534e5f5345504f4c4941"),
      index: 2,
      // accountDerivation: ArgentXAccountDerivation(),
    );
    // Braavos Account class hash - 0x00816dd0297efc55dc1e7559020a3a825e81ef734b558f03c83325d4da7e6253
    // Braavos Base Account base class hash- 0x013bfe114fb1cf405bfc3a7f8dbe2d91db146c17521d40dcf57e16d6b59fa8e6
    // westend 助记词下， braavos 公钥 0x127228b6eed607ae71cdeaf1c4cc455d0543101c9d545e948e14eec5177cffb
    // westend 助记词下， braavos 地址 0x06c2a560e3a2a1303699e24a6a9249ecb6e9a51163dada01b2ab0b8a43e24905
    // index = 1
    // 公钥 0x1c0ed1ec2190173d5900a76cea4c8c5611233614c9022388948ef8c43f515ad
    // 地址 0x261b745499c44af9e29138525025e988ad1d90d6d53cf0d2f91510073283bb5

    // index = 2
    // 公钥 0x3c6290c45853a34a75299999053c0ae436a2bfaf75ce57cbc93e634dc8ade36
    // 地址 0x69a6b083e5a586d78aaafe633168e16e822415bffc0d4dd1abcc99388c12c04

    print(account.signer.privateKey.toHexString());
    print(account.signer.publicKey.toHexString());
    print(account.accountAddress.toHexString());
    valid = await account.isValid;

    if (valid) {
      print("account deployed");

      return;
    }
    print("deploy");
    final braavosAccount =
        BraavosAccountDerivation(provider: provider, chainId: chainId);
    final deployTxHash = await braavosAccount.deploy(account: account);

    print("deployTxHash: ${deployTxHash.toHexString()}");
    final isAccepted = await waitForAcceptance(
      transactionHash: deployTxHash.toHexString(),
      provider: provider,
    );

    if (!isAccepted) {
      final receipt = await provider.getTransactionReceipt(deployTxHash);
      prettyPrintJson(receipt.toJson());
    } else {
      await printAccountInfo(account);
    }
    if (valid) {
      print("Address: ${account.accountAddress.toHexString()}");
      print("Public Key: ${account.signer.publicKey.toHexString()}");
      final balance = await account.balance();
      print("Balance: ${balance.toBigInt().toDouble() * 1e-18}");
    }
  }
}
