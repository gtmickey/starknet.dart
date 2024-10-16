import 'dart:typed_data';

import 'package:starknet/src/crypto/poseidon.dart';
import 'package:starknet/starknet.dart';

BigInt max128Bit = (BigInt.one << 128) - BigInt.one; // 最大 128 位整数
BigInt min128Bit = BigInt.zero; // 最小 128 位整数 (非负)

// 转换BigInt为 Uint8List（16 字节数组）,因为 dart 没有128位的int类型，
Uint8List toUint8List128(BigInt number) {
  if (number < min128Bit || number > max128Bit) {
    throw ArgumentError('Number is out of the 128-bit integer range');
  }
  final bytes = number.toRadixString(16).padLeft(32, '0');
  return Uint8List.fromList(List<int>.generate(
      16, (i) => int.parse(bytes.substring(i * 2, i * 2 + 2), radix: 16)));
}

class Signer {
  Felt privateKey;

  Signer({required this.privateKey});

  Felt get publicKey {
    final point = generatorPoint * privateKey.toBigInt();
    return Felt(point!.x!.toBigInteger()!);
  }

  List<Felt> signInvokeTransactionsV3({
    required List<FunctionCall> transactions,
    required Felt senderAddress,
    required Felt contractAddressSalt,
    required Felt classHash,
    required Felt chainId,
    required Felt nonce,
    required version,
    required Felt gas,
    required Felt gasPrice,
  }) {

    final calldata  = <Felt>[];
    for (var value in transactions) {
      calldata.add(value.contractAddress);
      calldata.add(value.entryPointSelector);
      calldata.addAll(value.calldata);
    }
    final transactionHash = getTransactionHashV3(
      prefix: TransactionHashPrefix.invoke,
      address: senderAddress,
      contractAddressSalt: contractAddressSalt,
      classHash: classHash,
      constructorCalldata: calldata,
      chainId: chainId,
      version: version!,
      nonce: nonce,
      gas: gas,
      gasPrice: gasPrice,
    );

    print("wtf transactionHash = ${transactionHash.toHexString()}");
    final signature = starknet_sign(
      privateKey: privateKey.toBigInt(),
      messageHash: transactionHash.toBigInt(),
      // seed: BigInt.from(32),
    );
    return [Felt(signature.r), Felt(signature.s)];
  }

  List<Felt> signInvokeTransactionsV1({
    required List<FunctionCall> transactions,
    required Felt senderAddress,
    required Felt chainId,
    required Felt nonce,
    Felt? version,
    Felt? maxFee,
    bool useLegacyCalldata = false,
  }) {
    maxFee = maxFee ?? defaultMaxFee;

    final calldata = functionCallsToCalldata(
      functionCalls: transactions,
      useLegacyCalldata: useLegacyCalldata,
    );

    final transactionHash = calculateTransactionHashCommon(
      txHashPrefix: TransactionHashPrefix.invoke.toBigInt(),
      address: senderAddress.toBigInt(),
      version: version?.toBigInt() ?? Felt.fromInt(1).toBigInt(),
      entryPointSelector: BigInt.parse("0"),
      calldata: toBigIntList(calldata),
      maxFee: maxFee.toBigInt(),
      chainId: chainId.toBigInt(),
      additionalData: [nonce.toBigInt()],
    );

    final signature = starknet_sign(
      privateKey: privateKey.toBigInt(),
      messageHash: transactionHash,
      // seed: BigInt.from(32),
    );
    return [Felt(signature.r), Felt(signature.s)];
  }

  List<Felt> signInvokeTransactionsV0({
    required List<FunctionCall> transactions,
    required Felt contractAddress,
    required Felt chainId,
    required Felt nonce,
    Felt? maxFee,
    String entryPointSelectorName = "__execute__",
  }) {
    maxFee = maxFee ?? defaultMaxFee;
    final calldata =
        functionCallsToCalldataLegacy(functionCalls: transactions) + [nonce];

    final transactionHash = calculateTransactionHashCommon(
      txHashPrefix: TransactionHashPrefix.invoke.toBigInt(),
      address: contractAddress.toBigInt(),
      version: Felt.fromInt(0).toBigInt(),
      entryPointSelector: getSelectorByName(entryPointSelectorName).toBigInt(),
      calldata: toBigIntList(calldata),
      maxFee: maxFee.toBigInt(),
      chainId: chainId.toBigInt(),
    );

    final signature = starknet_sign(
      privateKey: privateKey.toBigInt(),
      messageHash: transactionHash,
      seed: BigInt.from(32),
    );

    return [Felt(signature.r), Felt(signature.s)];
  }

  List<Felt> signTransactions({
    required List<FunctionCall> transactions,
    required Felt contractAddress,
    required Felt chainId,
    required int version,
    required Felt nonce,
    Felt? maxFee,
    Felt? gas,
    Felt? gasPrice,
    String entryPointSelectorName = "__execute__",
    bool useLegacyCalldata = false,
    bool isBraavos = false,
    bool queryOnly = false,
    Felt? classHash,
    Felt? contractAddressSalt,
  }) {
    switch (version) {
      case 0:
        print("Signing invoke transaction v0");
        return signInvokeTransactionsV0(
          transactions: transactions,
          contractAddress: contractAddress,
          chainId: chainId,
          entryPointSelectorName: entryPointSelectorName,
          nonce: nonce,
          maxFee: maxFee,
        );
      case 1:
        return signInvokeTransactionsV1(
            transactions: transactions,
            senderAddress: contractAddress,
            chainId: chainId,
            nonce: nonce,
            version: queryOnly
                ? Felt.fromHexString("0x100000000000000000000000000000001")
                : Felt.fromInt(1),
            maxFee: maxFee,
            useLegacyCalldata: useLegacyCalldata);

      case 3:
        assert(gas != null);
        assert(gasPrice != null);
        assert(classHash != null);
        assert(contractAddressSalt != null);
        return signInvokeTransactionsV3(
          transactions: transactions,
          senderAddress: contractAddress,
          chainId: chainId,
          nonce: nonce,
          version: queryOnly
              ? Felt.fromHexString("0x100000000000000000000000000000003")
              : Felt.fromInt(3),
          gas: gas!,
          gasPrice: gasPrice!,
          classHash: classHash!,
          contractAddressSalt: contractAddressSalt!,
        );
      default:
        throw Exception("Unsupported invoke transaction version: $version");
    }
  }

  List<Felt> signDeclareTransactionV1({
    required DeprecatedCompiledContract compiledContract,
    required Felt senderAddress,
    required Felt chainId,
    required Felt nonce,
    Felt? maxFee,
  }) {
    maxFee = maxFee ?? defaultMaxFee;

    final classHash = compiledContract.classHash();
    final List<BigInt> elementsToHash = [
      TransactionHashPrefix.declare.toBigInt(),
      BigInt.from(1),
      senderAddress.toBigInt(),
      BigInt.from(0),
      computeHashOnElements([classHash]),
      maxFee.toBigInt(),
      chainId.toBigInt(),
      nonce.toBigInt()
    ];
    final transactionHash = computeHashOnElements(elementsToHash);

    final signature = starknet_sign(
      privateKey: privateKey.toBigInt(),
      messageHash: transactionHash,
      seed: BigInt.from(32),
    );

    return [Felt(signature.r), Felt(signature.s)];
  }

  List<Felt> signDeclareTransactionV2({
    required CompiledContract compiledContract,
    required Felt senderAddress,
    required Felt chainId,
    required Felt nonce,
    Felt? maxFee,
    BigInt? classHash,
    BigInt? compiledClassHash,
    CASMCompiledContract? casmCompiledContract,
  }) {
    maxFee = maxFee ?? defaultMaxFee;

    classHash ??= compiledContract.classHash();
    if ((compiledClassHash == null) && (casmCompiledContract == null)) {
      throw Exception(
        "compiledClassHash is null and CASM contract not provided",
      );
    }
    compiledClassHash ??= casmCompiledContract!.classHash();

    final List<BigInt> elementsToHash = [
      TransactionHashPrefix.declare.toBigInt(),
      BigInt.two,
      senderAddress.toBigInt(),
      BigInt.zero,
      computeHashOnElements([classHash]),
      maxFee.toBigInt(),
      chainId.toBigInt(),
      nonce.toBigInt(),
      compiledClassHash,
    ];

    final transactionHash = computeHashOnElements(elementsToHash);

    final signature = starknet_sign(
      privateKey: privateKey.toBigInt(),
      messageHash: transactionHash,
      seed: BigInt.from(32),
    );

    return [Felt(signature.r), Felt(signature.s)];
  }

  List<Felt> signDeployAccountTransactionV1({
    required Felt contractAddressSalt,
    required Felt classHash,
    required List<Felt> constructorCalldata,
    required Felt chainId,
    Felt? nonce,
    Felt? maxFee,
  }) {
    maxFee = maxFee ?? defaultMaxFee;
    nonce = nonce ?? defaultNonce;
    final contractAddress = Contract.computeAddress(
      classHash: classHash,
      calldata: constructorCalldata,
      salt: contractAddressSalt,
    );
    final transactionHash = calculateTransactionHashCommon(
      txHashPrefix: TransactionHashPrefix.deployAccount.toBigInt(),
      version: Felt.fromInt(1).toBigInt(),
      address: contractAddress.toBigInt(),
      entryPointSelector: BigInt.from(0),
      calldata: toBigIntList([
        classHash,
        contractAddressSalt,
        ...constructorCalldata,
      ]),
      maxFee: maxFee.toBigInt(),
      chainId: chainId.toBigInt(),
      additionalData: [nonce.toBigInt()],
    );

    final signature = starknet_sign(
      privateKey: privateKey.toBigInt(),
      messageHash: transactionHash,
    );

    return [Felt(signature.r), Felt(signature.s)];
  }

  List<Felt> signBraavosDeployAccountTransactionV1({
    required Felt contractAddressSalt,
    required Felt classHash,
    required Felt baseClassHash,
    required List<Felt> constructorCalldata,
    required Felt chainId,
    Felt? nonce,
    Felt? maxFee,
  }) {
    maxFee = maxFee ?? defaultMaxFee;
    nonce = nonce ?? defaultNonce;
    final contractAddress = Contract.computeAddress(
      classHash: baseClassHash,
      calldata: constructorCalldata,
      salt: contractAddressSalt,
    );

    final transactionHash = calculateTransactionHashCommon(
      txHashPrefix: TransactionHashPrefix.deployAccount.toBigInt(),
      version: Felt.fromInt(1).toBigInt(),
      address: contractAddress.toBigInt(),
      entryPointSelector: BigInt.from(0),
      calldata: toBigIntList([
        baseClassHash,
        contractAddressSalt,
        ...constructorCalldata,
      ]),
      maxFee: maxFee.toBigInt(),
      chainId: chainId.toBigInt(),
      additionalData: [nonce.toBigInt()],
    );

    final signature = starknet_sign(
      privateKey: privateKey.toBigInt(),
      messageHash: transactionHash,
    );

    final aux = [
      // account_implementation
      classHash,
      // signer_type
      Felt.fromInt(0),
      // secp256r1_signer.x.low
      Felt.fromInt(0),
      // secp256r1_signer.x.high
      Felt.fromInt(0),
      // secp256r1_signer.y.low
      Felt.fromInt(0),
      // secp256r1_signer.y.high
      Felt.fromInt(0),
      // multisig_threshold
      Felt.fromInt(0),
      // withdrawal_limit_low
      Felt.fromInt(0),
      // fee_rate
      Felt.fromInt(0),
      // stark_fee_rate
      Felt.fromInt(0),
      chainId,
    ];

    final auxHash =
        poseidonHasher.hashMany(aux.map((e) => e.toBigInt()).toList());
    final auxSignature = starknet_sign(
      privateKey: privateKey.toBigInt(),
      messageHash: auxHash,
    );

    final result = [Felt(signature.r), Felt(signature.s)];
    result.addAll(aux);
    result.add(Felt(auxSignature.r));
    result.add(Felt(auxSignature.s));
    return result;
  }

  List<Felt> signArgentDeployAccountTransactionV1({
    required Felt contractAddressSalt,
    required Felt classHash,
    required List<Felt> constructorCalldata,
    required Felt chainId,
    Felt? nonce,
    Felt? maxFee,
  }) {
    maxFee = maxFee ?? defaultMaxFee;
    nonce = nonce ?? defaultNonce;
    final contractAddress = Contract.computeAddress(
      classHash: classHash,
      calldata: constructorCalldata,
      salt: contractAddressSalt,
    );

    final transactionHash = calculateTransactionHashCommon(
      txHashPrefix: TransactionHashPrefix.deployAccount.toBigInt(),
      version: Felt.fromInt(1).toBigInt(),
      address: contractAddress.toBigInt(),
      entryPointSelector: BigInt.from(0),
      calldata: toBigIntList([
        classHash,
        contractAddressSalt,
        ...constructorCalldata,
      ]),
      maxFee: maxFee.toBigInt(),
      chainId: chainId.toBigInt(),
      additionalData: [nonce.toBigInt()],
    );

    final signature = starknet_sign(
      privateKey: privateKey.toBigInt(),
      messageHash: transactionHash,
    );

    return [Felt(signature.r), Felt(signature.s)];
  }

  List<Felt> signArgentDeployAccountTransactionV3({
    required Felt address,
    required Felt contractAddressSalt,
    required Felt classHash,
    required List<Felt> constructorCalldata,
    required Felt chainId,
    required Felt version,
    required Felt nonce,
    required Felt gas,
    required Felt gasPrice,
  }) {
    ///dart impl, starknet-accounts/src/factory/mod.rs, v3 [transaction_hash]  line ~980 ,
    final hasher = newPoseidonHasher();

    hasher.update(TransactionHashPrefix.deployAccount.toBigInt());
    hasher.update(version.toBigInt());
    hasher.update(address.toBigInt());

    final feeHasher = newPoseidonHasher();
    feeHasher.update(BigInt.zero);

    Uint8List resourceBufferL1 = Uint8List(32);
    resourceBufferL1.setAll(0, [
      0,
      0,
      'L'.codeUnitAt(0),
      '1'.codeUnitAt(0),
      '_'.codeUnitAt(0),
      'G'.codeUnitAt(0),
      'A'.codeUnitAt(0),
      'S'.codeUnitAt(0),
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ]);
    // 转换 gas 为字节并填充
    ByteData gasData = ByteData(8);
    gasData.setInt64(0, gas.toInt());
    Uint8List gasBytes = gasData.buffer.asUint8List();
    resourceBufferL1.setRange(8, 16, gasBytes);

    // 转换 gasPrice 为字节并填充
    // ByteData gasPriceData = ByteData(16);
    // gasPriceData.setUint64(0, gasPrice.toInt());
    // Uint8List gasPriceBytes = gasPriceData.buffer.asUint8List();
    // resourceBufferL1.setRange(16, 32, gasPriceBytes);

    Uint8List gasPriceBytes = toUint8List128(gasPrice.toBigInt());
    print("wtf gasPriceBytes = ${gasPriceBytes.length}");

    resourceBufferL1.setRange(16, 32, gasPriceBytes);
    print("wtf resourceBufferL1 = ${resourceBufferL1}");

    feeHasher.update(Felt.fromBytes(resourceBufferL1).toBigInt());

    Uint8List resourceBufferL2 = Uint8List(32);
    resourceBufferL2.setAll(0, [
      0,
      0,
      'L'.codeUnitAt(0),
      '2'.codeUnitAt(0),
      '_'.codeUnitAt(0),
      'G'.codeUnitAt(0),
      'A'.codeUnitAt(0),
      'S'.codeUnitAt(0),
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ]);

    feeHasher.update(Felt.fromBytes(resourceBufferL2).toBigInt());
    final feeHash = feeHasher.finalize();
    hasher.update(feeHash);

    // Hard-coded empty `paymaster_data`
    hasher.update(newPoseidonHasher().finalize());

    hasher.update(chainId.toBigInt());
    hasher.update(nonce.toBigInt());

    // Hard-coded L1 DA mode for nonce and fee
    hasher.update(BigInt.zero);

    final callDataHasher = newPoseidonHasher();
    for (Felt c in constructorCalldata) {
      callDataHasher.update(c.toBigInt());
    }
    final calldatahash = callDataHasher.finalize();

    hasher.update(calldatahash);

    hasher.update(classHash.toBigInt());
    hasher.update(contractAddressSalt.toBigInt());

    final messageHash = hasher.finalize();

    print("wtf  deploy messageHash ${Felt(messageHash).toHexString()}");

    print("wtf deploy privateKey ${privateKey.toHexString()} ");
    final signature = starknet_sign(
      privateKey: privateKey.toBigInt(),
      messageHash: messageHash,
    );

    return [Felt(signature.r), Felt(signature.s)];
  }

  Felt getTransactionHashV3({
    required Felt prefix,
    required Felt address,
    required Felt contractAddressSalt,
    required Felt classHash,
    required List<Felt> constructorCalldata,
    required Felt chainId,
    required Felt version,
    required Felt nonce,
    required Felt gas,
    required Felt gasPrice,
  }) {
    ///dart impl, starknet-accounts/src/factory/mod.rs, v3 [transaction_hash]  line ~980 ,
    final hasher = newPoseidonHasher();

    hasher.update(prefix.toBigInt());
    hasher.update(version.toBigInt());
    hasher.update(address.toBigInt());


    final feeHasher = newPoseidonHasher();
    feeHasher.update(BigInt.zero);

    Uint8List resourceBufferL1 = Uint8List(32);
    resourceBufferL1.setAll(0, [
      0,
      0,
      'L'.codeUnitAt(0),
      '1'.codeUnitAt(0),
      '_'.codeUnitAt(0),
      'G'.codeUnitAt(0),
      'A'.codeUnitAt(0),
      'S'.codeUnitAt(0),
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ]);
    // 转换 gas 为字节并填充
    ByteData gasData = ByteData(8);
    gasData.setInt64(0, gas.toInt());
    Uint8List gasBytes = gasData.buffer.asUint8List();
    resourceBufferL1.setRange(8, 16, gasBytes);

    // 转换 gasPrice 为字节并填充
    // ByteData gasPriceData = ByteData(16);
    // gasPriceData.setUint64(0, gasPrice.toInt());
    // Uint8List gasPriceBytes = gasPriceData.buffer.asUint8List();
    // resourceBufferL1.setRange(16, 32, gasPriceBytes);

    Uint8List gasPriceBytes = toUint8List128(gasPrice.toBigInt());
    print("wtf gasPriceBytes = ${gasPriceBytes.length}");

    resourceBufferL1.setRange(16, 32, gasPriceBytes);
    print("wtf resourceBufferL1 = ${resourceBufferL1}");

    feeHasher.update(Felt.fromBytes(resourceBufferL1).toBigInt());

    Uint8List resourceBufferL2 = Uint8List(32);
    resourceBufferL2.setAll(0, [
      0,
      0,
      'L'.codeUnitAt(0),
      '2'.codeUnitAt(0),
      '_'.codeUnitAt(0),
      'G'.codeUnitAt(0),
      'A'.codeUnitAt(0),
      'S'.codeUnitAt(0),
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ]);

    feeHasher.update(Felt.fromBytes(resourceBufferL2).toBigInt());

    print("wtf resourceBufferL2 = ${resourceBufferL2}");
    final feeHash = feeHasher.finalize();
    hasher.update(feeHash);

    // Hard-coded empty `paymaster_data`
    hasher.update(newPoseidonHasher().finalize());

    hasher.update(chainId.toBigInt());
    hasher.update(nonce.toBigInt());

    // Hard-coded L1 DA mode for nonce and fee
    hasher.update(BigInt.zero);

    final callDataHasher = newPoseidonHasher();
    for (Felt c in constructorCalldata) {
      callDataHasher.update(c.toBigInt());
    }
    final calldatahash = callDataHasher.finalize();

    hasher.update(calldatahash);

    hasher.update(classHash.toBigInt());
    hasher.update(contractAddressSalt.toBigInt());

    return Felt(hasher.finalize());
  }
}
