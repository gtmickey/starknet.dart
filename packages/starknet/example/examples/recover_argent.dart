import 'package:starknet/starknet.dart';

final mnemonic =
    "fiscal document grain ecology wheat around sport nice guitar topple north add";

void main() async {
  final provider = JsonRpcProvider(nodeUri: devnetUri);
  final chainId = StarknetChainId.testNet;
  final accountDerivation =
      ArgentXAccountDerivation(provider: provider, chainId: chainId);
  print("Retrieving OpenZeppelin accounts");
  int index = 2;
  // bool valid = true;
  // while (valid) {
  print("########################");
  final account = Account.fromMnemonic(
    mnemonic: mnemonic,
    provider: provider,
    chainId: chainId,
    index: index,
    accountDerivation: accountDerivation,
  );
  final ADDR_BOUND = BigInt.from(2).pow(251) - BigInt.from(256);
  final re = account.accountAddress.toBigInt() % ADDR_BOUND;
  print("re: ${Felt(re).toHexString()}");
  print("privatekey: ${account.signer.privateKey.toHexString()}");
  print("public key: ${account.signer.publicKey.toHexString()}");
  print("public key: ${account.signer.publicKey.toBigInt()}");
  print("Address: ${account.accountAddress.toHexString()}");
  // index += 1;
  // valid = await account.isValid;
  // if (valid) {
  //   print("Address: ${account.accountAddress.toHexString()}");
  //   print("Public Key: ${account.signer.publicKey.toHexString()}");
  //   final balance = await account.balance();
  //   print("Balance: ${balance.toBigInt().toDouble() * 1e-18}");
  // }
  // }
}
