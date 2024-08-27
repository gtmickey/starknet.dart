// Generated code, do not modify. Run `build_runner build` to re-generate!
// ignore_for_file: unused_element

import 'package:starknet/starknet.dart';

class Udc extends Contract {
  Udc({
    required super.account,
    required super.address,
  });

  Future<String> deployContract(
    Felt classHash,
    Felt salt,
    Felt unique,
    List<Felt> calldata, {
    Felt? maxFee,
  }) async {
    final List<Felt> params = [
      classHash,
      salt,
      unique,
      ...calldata.toCallData(),
    ];
    final trx = await execute(
      'deployContract',
      params,
      maxFee ?? defaultMaxFee,
    );
    final trxHash = trx.when(
      result: (result) => result.transaction_hash,
      error: (error) => throw Exception,
    );
    return trxHash;
  }
}

extension on List<Felt> {
  List<Felt> toCallData() {
    return [
      Felt.fromInt(length),
      ...this,
    ];
  }

  List<Felt> fromCallData() {
    return sublist(1);
  }
}
