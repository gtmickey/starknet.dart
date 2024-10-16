import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:starknet/src/presets/udc.g.dart';
import 'package:starknet/starknet.dart';

enum AccountSupportedTxVersion {
  @Deprecated("Transaction version 0 will be removed with Starknet alpha v0.11")
  v0,
  v1,
  v3,
}

class AccountInfo {
  late Felt privateKey;
  late Felt publicKey;
  late Felt address;

  AccountInfo(this.privateKey, this.publicKey, this.address);
}

class EstimateFeeModel {
  late Felt gasConsumed;
  late Felt gasPrice;
  late Felt overallFee;

  EstimateFeeModel({
    required this.gasConsumed,
    required this.gasPrice,
    required this.overallFee,
  });
}

class GasFeeV3 {
  late Felt gas;
  late Felt gasPrice;
  late Felt overallFee;

  GasFeeV3({
    required this.gas,
    required this.gasPrice,
    required this.overallFee,
  });

  @override
  String toString() {
    return {
      "gas": gas.toBigInt(),
      "gasPrice": gasPrice.toBigInt(),
      "overallFee": overallFee.toBigInt(),
    }.toString();
  }
}

/// Account abstraction class
class Account {
  Provider provider;
  Signer signer;
  Felt accountAddress;
  Felt chainId;
  AccountSupportedTxVersion supportedTxVersion;

  Account({
    required this.provider,
    required this.signer,
    required this.accountAddress,
    required this.chainId,
    this.supportedTxVersion = AccountSupportedTxVersion.v1,
  });

  /// Get Nonce for account at given [blockId]
  Future<Felt> getNonce([BlockId blockId = BlockId.latest]) async {
    final response = await provider.getNonce(
      blockId: blockId,
      contractAddress: accountAddress,
    );
    return (response.when(
      error: (error) {
        throw Exception(
            "Error retrieving nonce (${error.code}): ${error.message}");
      },
      result: (result) => result,
    ));
  }

  /// Get Estimate max fee for Invoke Tx
  Future<Felt> getEstimateMaxFeeForInvokeTx({
    BlockId blockId = BlockId.latest,
    String version = "0x1",
    required List<FunctionCall> functionCalls,
    bool useLegacyCalldata = false,
    required Felt nonce,
    double feeMultiplier = 1.2,
  }) async {
    final signature = signer.signTransactions(
      transactions: functionCalls,
      contractAddress: accountAddress,
      version: supportedTxVersion == AccountSupportedTxVersion.v1 ? 1 : 0,
      chainId: chainId,
      entryPointSelectorName: "__execute__",
      nonce: nonce,
      useLegacyCalldata: useLegacyCalldata,
    );

    BroadcastedTxn broadcastedTxn;

    if (version == "0x1") {
      final calldata = functionCallsToCalldata(
        functionCalls: functionCalls,
        useLegacyCalldata: useLegacyCalldata,
      );
      broadcastedTxn = BroadcastedInvokeTxnV1(
          type: "INVOKE",
          maxFee: defaultMaxFee,
          version: version,
          signature: signature,
          nonce: nonce,
          senderAddress: accountAddress,
          calldata: calldata);
    } else {
      final calldata =
          functionCallsToCalldataLegacy(functionCalls: functionCalls) + [nonce];
      broadcastedTxn = BroadcastedInvokeTxnV0(
          type: "INVOKE",
          maxFee: defaultMaxFee,
          version: version,
          signature: signature,
          nonce: nonce,
          contractAddress: accountAddress,
          entryPointSelector: getSelectorByName('__execute__'),
          calldata: calldata);
    }

    final maxFee = await getMaxFeeFromBroadcastedTxn(
        broadcastedTxn, blockId, feeMultiplier);

    return maxFee;
  }

  /// Get Estimate max fee for Invoke Tx
  Future<Felt> getEstimateMaxFeeForBraavosInvokeTx({
    BlockId blockId = BlockId.latest,
    String version = "0x1",
    required List<FunctionCall> functionCalls,
    bool useLegacyCalldata = false,
    required Felt nonce,
    double feeMultiplier = 1.2,
  }) async {
    final signature = signer.signTransactions(
      transactions: functionCalls,
      contractAddress: accountAddress,
      version: supportedTxVersion == AccountSupportedTxVersion.v1 ? 1 : 0,
      chainId: chainId,
      entryPointSelectorName: "__execute__",
      nonce: nonce,
      queryOnly: true,
      useLegacyCalldata: useLegacyCalldata,
      maxFee: Felt.fromInt(0),
    );
    BroadcastedTxn broadcastedTxn;

    if (version == "0x1") {
      final calldata = functionCallsToCalldata(
        functionCalls: functionCalls,
        useLegacyCalldata: useLegacyCalldata,
      );
      broadcastedTxn = BroadcastedInvokeTxnV1(
          type: "INVOKE",
          maxFee: defaultMaxFee,
          version: "0x100000000000000000000000000000001",
          // queryOnly
          signature: signature,
          nonce: nonce,
          senderAddress: accountAddress,
          calldata: calldata);
    } else {
      final calldata =
          functionCallsToCalldataLegacy(functionCalls: functionCalls) + [nonce];
      broadcastedTxn = BroadcastedInvokeTxnV0(
          type: "INVOKE",
          maxFee: Felt.fromInt(0),
          version: version,
          signature: signature,
          nonce: nonce,
          contractAddress: accountAddress,
          entryPointSelector: getSelectorByName('__execute__'),
          calldata: calldata);
    }

    final maxFee = await getMaxFeeFromBroadcastedTxn(
        broadcastedTxn, blockId, feeMultiplier);

    return maxFee;
  }

  /// Get Estimate max fee for Invoke Tx
  Future<Felt> getEstimateMaxFeeForArgentInvokeTx({
    BlockId blockId = const BlockId.blockTag("pending"),
    required String version,
    required List<FunctionCall> functionCalls,
    bool useLegacyCalldata = false,
    required Felt nonce,
    double feeMultiplier = 1.2,
    String nonceDataAvailabilityMode = "L1",
    String feeDataAvailabilityMode = "L1",
  }) async {
    final signature = signer.signTransactions(
      transactions: functionCalls,
      contractAddress: accountAddress,
      version: supportedTxVersion == AccountSupportedTxVersion.v1 ? 1 : 0,
      chainId: chainId,
      entryPointSelectorName: "__execute__",
      nonce: nonce,
      queryOnly: true,
      useLegacyCalldata: useLegacyCalldata,
      maxFee: Felt.fromInt(0),
    );

    BroadcastedTxn broadcastedTxn;

    if (version == "0x1") {
      final calldata = functionCallsToCalldata(
        functionCalls: functionCalls,
        useLegacyCalldata: useLegacyCalldata,
      );
      broadcastedTxn = BroadcastedInvokeTxnV1(
          type: "INVOKE",
          maxFee: defaultMaxFee,
          version: "0x100000000000000000000000000000001",
          // queryOnly
          signature: signature,
          nonce: nonce,
          senderAddress: accountAddress,
          calldata: calldata);
    } else {
      final calldata =
          functionCallsToCalldataLegacy(functionCalls: functionCalls) + [nonce];
      broadcastedTxn = BroadcastedInvokeTxnV0(
          type: "INVOKE",
          maxFee: Felt.fromInt(0),
          version: version,
          signature: signature,
          nonce: nonce,
          contractAddress: accountAddress,
          entryPointSelector: getSelectorByName('__execute__'),
          calldata: calldata);
    }

    final maxFee = await getMaxFeeFromBroadcastedTxn(
        broadcastedTxn, blockId, feeMultiplier);

    return maxFee;
  }

  Future<GasFeeV3> getEstimateMaxFeeForArgentInvokeTxV3({
    BlockId blockId = const BlockId.blockTag("pending"),
    required List<FunctionCall> functionCalls,
    bool useLegacyCalldata = false,
    required Felt nonce,
    double feeMultiplier = 1.5,
    String nonceDataAvailabilityMode = "L1",
    String feeDataAvailabilityMode = "L1",
    required Felt gas,
    required Felt gasPrice,
    required Felt classHash,
    required Felt contractAddressSalt,
  }) async {
    final signature = signer.signTransactions(
      transactions: functionCalls,
      contractAddress: accountAddress,
      version: 3,
      chainId: chainId,
      entryPointSelectorName: "__execute__",
      nonce: nonce,
      queryOnly: true,
      useLegacyCalldata: useLegacyCalldata,
      maxFee: Felt.fromInt(0),
      gas: gas,
      gasPrice: gasPrice,
      classHash: classHash,
      contractAddressSalt: contractAddressSalt,
    );

    BroadcastedTxn broadcastedTxn;

    final calldata = functionCallsToCalldata(
      functionCalls: functionCalls,
      useLegacyCalldata: useLegacyCalldata,
    );
    broadcastedTxn = BroadcastedInvokeTxnV3(
      type: "INVOKE",
      version: "0x100000000000000000000000000000003",
      // queryOnly
      signature: signature,
      nonce: nonce,
      senderAddress: accountAddress,
      calldata: calldata,
      accountDeploymentData: [],
      feeDataAvailabilityMode: feeDataAvailabilityMode,
      nonceDataAvailabilityMode: nonceDataAvailabilityMode,
      paymasterData: [],
      resourceBounds: {
        "l1_gas": {"max_amount": "0x0", "max_price_per_unit": "0x0"},
        "l2_gas": {"max_amount": "0x0", "max_price_per_unit": "0x0"}
      },
      tip: Felt.fromHexString('0x0'), // 根据官方文档，目前总是0
    );

    final feeV3 = await getFeeFromBroadcastedTxnV3(
        broadcastedTxn, blockId, feeMultiplier);
    return feeV3;
  }

  /// Get Estimate max fee for Declare Tx
  Future<Felt> getEstimateMaxFeeForDeclareTx({
    BlockId blockId = BlockId.latest,
    String version = "0x1",
    required Felt nonce,
    required ICompiledContract compiledContract,
    double feeMultiplier = 1.2,
  }) async {
    BroadcastedTxn broadcastedTxn;

    if (compiledContract is DeprecatedCompiledContract) {
      final signature = signer.signDeclareTransactionV1(
        compiledContract: compiledContract,
        senderAddress: accountAddress,
        chainId: chainId,
        nonce: nonce,
      );
      broadcastedTxn = BroadcastedDeclareTxn(
          type: "DECLARE",
          maxFee: defaultMaxFee,
          version: version,
          signature: signature,
          nonce: nonce,
          contractClass: compiledContract.compress(),
          senderAddress: accountAddress);
    } else {
      // V2 of BroadcastedDeclareTxn is not supported yet
      return defaultMaxFee;
    }

    final maxFee = await getMaxFeeFromBroadcastedTxn(
        broadcastedTxn, blockId, feeMultiplier);

    return maxFee;
  }

  /// Get Estimate max fee for Deploy Tx
  Future<Felt> getEstimateMaxFeeForDeployAccountTx({
    BlockId blockId = BlockId.latest,
    String version = "0x1",
    required Felt nonce,
    required List<Felt> constructorCalldata,
    required Felt contractAddressSalt,
    required Felt classHash,
    double feeMultiplier = 1.2,
  }) async {
    final signature = signer.signDeployAccountTransactionV1(
      contractAddressSalt: contractAddressSalt,
      classHash: classHash,
      constructorCalldata: constructorCalldata,
      chainId: chainId,
      nonce: nonce,
    );

    final broadcastedTxn = BroadcastedDeployAccountTxn(
        type: "DEPLOY_ACCOUNT",
        version: version,
        contractAddressSalt: contractAddressSalt,
        constructorCalldata: constructorCalldata,
        maxFee: defaultMaxFee,
        nonce: nonce,
        signature: signature,
        classHash: classHash);

    final maxFee = await getMaxFeeFromBroadcastedTxn(
        broadcastedTxn, blockId, feeMultiplier);

    return maxFee;
  }

  Future<Felt> getEstimateMaxFeeForArgentDeployAccountTx({
    BlockId blockId = BlockId.latest,
    String version = "0x1",
    required Felt nonce,
    required List<Felt> constructorCalldata,
    required Felt contractAddressSalt,
    required Felt classHash,
    double feeMultiplier = 1.5,
  }) async {
    final signature = signer.signArgentDeployAccountTransactionV1(
      contractAddressSalt: contractAddressSalt,
      classHash: classHash,
      constructorCalldata: constructorCalldata,
      chainId: chainId,
      nonce: nonce,
      maxFee: Felt.fromInt(0),
    );

    final broadcastedTxn = BroadcastedDeployAccountTxn(
      type: "DEPLOY_ACCOUNT",
      version: version,
      contractAddressSalt: contractAddressSalt,
      constructorCalldata: constructorCalldata,
      maxFee: Felt.fromInt(0),
      nonce: nonce,
      signature: signature,
      classHash: classHash,
    );

    final maxFee = await getMaxFeeFromBroadcastedTxn(
        broadcastedTxn, blockId, feeMultiplier);

    return maxFee;
  }

  Future<GasFeeV3> getEstimateMaxFeeForArgentDeployAccountV3Tx({
    BlockId blockId = BlockId.latest,
    String version = "0x100000000000000000000000000000003",
    required Felt address,
    required Felt nonce,
    required List<Felt> constructorCalldata,
    required Felt contractAddressSalt,
    required Felt classHash,
    String nonceDataAvailabilityMode = "L1",
    String feeDataAvailabilityMode = "L1",
    double feeMultiplier = 1.0,
  }) async {
    final signature = signer.signArgentDeployAccountTransactionV3(
      address: address,
      contractAddressSalt: contractAddressSalt,
      classHash: classHash,
      constructorCalldata: constructorCalldata,
      chainId: chainId,
      nonce: nonce,
      version: Felt.fromHexString(version),
      gas: Felt.fromInt(0),
      gasPrice: Felt.fromInt(0),
    );

    print("wtf  deploy signature  r ${signature.first.toHexString()}");
    print("wtf  deploy signature s ${signature.last.toHexString()}");

    final broadcastedTxnV3 = BroadcastedDeployAccountTxnV3(
      type: "DEPLOY_ACCOUNT",
      version: version,
      contractAddressSalt: contractAddressSalt,
      constructorCalldata: constructorCalldata,
      nonce: nonce,
      signature: signature,
      classHash: classHash,
      feeDataAvailabilityMode: feeDataAvailabilityMode,
      nonceDataAvailabilityMode: nonceDataAvailabilityMode,
      paymasterData: [],
      resourceBounds: {
        "l1_gas": {"max_amount": "0x0", "max_price_per_unit": "0x0"},
        "l2_gas": {"max_amount": "0x0", "max_price_per_unit": "0x0"}
      },
      tip: Felt.fromHexString('0x0'), // 根据官方文档，目前总是0
    );

    final fee = await getFeeFromBroadcastedTxnV3(
      broadcastedTxnV3,
      blockId,
      feeMultiplier,
    );

    return fee;
  }

  Future<Felt> getEstimateMaxFeeForBraavosDeployAccountTx({
    BlockId blockId = BlockId.latest,
    String version = "0x1",
    required Felt nonce,
    required List<Felt> constructorCalldata,
    required Felt contractAddressSalt,
    required Felt classHash,
    required Felt baseClassHash,
    double feeMultiplier = 1.2,
  }) async {
    final signature = signer.signBraavosDeployAccountTransactionV1(
      contractAddressSalt: contractAddressSalt,
      classHash: classHash,
      baseClassHash: baseClassHash,
      constructorCalldata: constructorCalldata,
      chainId: chainId,
      nonce: nonce,
      maxFee: Felt.fromInt(0),
    );

    for (Felt x in signature) {
      print("signature = ${x.toHexString()}");
    }
    final broadcastedTxn = BroadcastedDeployAccountTxn(
        type: "DEPLOY_ACCOUNT",
        version: version,
        contractAddressSalt: contractAddressSalt,
        constructorCalldata: constructorCalldata,
        maxFee: Felt.fromInt(0),
        nonce: nonce,
        signature: signature,
        classHash: baseClassHash);

    final maxFee = await getMaxFeeFromBroadcastedTxn(
        broadcastedTxn, blockId, feeMultiplier);

    return maxFee;
  }

  Future<Felt> getMaxFeeFromBroadcastedTxn(
    BroadcastedTxn broadcastedTxn,
    BlockId blockId,
    double feeMultiplier,
  ) async {
    EstimateFeeRequest estimateFeeRequest = EstimateFeeRequest(
      request: [broadcastedTxn],
      blockId: blockId,
      simulation_flags: [],
    );

    final estimateFeeResponse = await provider.estimateFee(
      estimateFeeRequest,
    );

    final fee = estimateFeeResponse.when(
      result: (result) => result[0],
      error: (error) => throw Exception(error.message),
    );

    final Felt overallFee = Felt.fromHexString(fee.overallFee);
    //multiply by feeMultiplier
    final Felt maxFee =
        Felt.fromDouble(overallFee.toBigInt().toDouble() * feeMultiplier);

    return maxFee;
  }

  Future<GasFeeV3> getFeeFromBroadcastedTxnV3(
    BroadcastedTxn broadcastedTxn,
    BlockId blockId,
    double feeMultiplier,
  ) async {
    EstimateFeeRequest estimateFeeRequest = EstimateFeeRequest(
      request: [broadcastedTxn],
      blockId: blockId,
      simulation_flags: [],
    );

    final estimateFeeResponse = await provider.estimateFee(
      estimateFeeRequest,
    );

    final fee = estimateFeeResponse.when(
      result: (result) => result[0],
      error: (error) => throw Exception(error.message),
    );

    final Felt overallFee = Felt.fromHexString(fee.overallFee);
    final Felt gasConsumed = Felt.fromHexString(fee.gasConsumed);
    final Felt gasPrice = Felt.fromHexString(fee.gasPrice);

    //公式来源  starknet-accounts/src/account/execution.rs 文件  469行和484行
    /// v3 gas 费用计算
    /// gas = (overall_fee + gas_price - 1) / gas_price * 1.5
    /// gas_price = gas_price * 1.5

    final finalGas = Felt.fromDouble(
        (overallFee.toBigInt() + gasPrice.toBigInt() - BigInt.one).toDouble() /
            gasPrice.toBigInt().toDouble() *
            feeMultiplier);

    final finalGasPrice =
        Felt.fromDouble(gasPrice.toBigInt().toDouble() * feeMultiplier);

    return GasFeeV3(
      gas: finalGas,
      gasPrice: finalGasPrice,
      overallFee: overallFee,
    );
  }

  /// Call account contract `__execute__` with given [functionCalls]
  Future<InvokeTransactionResponse> execute({
    required List<FunctionCall> functionCalls,
    bool useLegacyCalldata = false,
    required Felt maxFee,
    Felt? nonce,
    String feeDataAvailabilityMode = 'L1',
    String nonceDataAvailabilityMode = 'L1',
  }) async {
    nonce = nonce ?? await getNonce();

    switch (supportedTxVersion) {
      // ignore: deprecated_member_use_from_same_package
      case AccountSupportedTxVersion.v0:
        final signature = signer.signTransactions(
          transactions: functionCalls,
          contractAddress: accountAddress,
          version: supportedTxVersion == AccountSupportedTxVersion.v1 ? 1 : 0,
          chainId: chainId,
          entryPointSelectorName: "__execute__",
          nonce: nonce,
          useLegacyCalldata: useLegacyCalldata,
          maxFee: maxFee,
        );

        final calldata =
            functionCallsToCalldataLegacy(functionCalls: functionCalls) +
                [nonce];

        return provider.addInvokeTransaction(
          InvokeTransactionRequest(
            invokeTransaction: InvokeTransactionV0(
              contractAddress: accountAddress,
              entryPointSelector: getSelectorByName('__execute__'),
              calldata: calldata,
              maxFee: maxFee,
              signature: signature,
            ),
          ),
        );
      case AccountSupportedTxVersion.v1:
        final signature = signer.signTransactions(
          transactions: functionCalls,
          contractAddress: accountAddress,
          version: supportedTxVersion == AccountSupportedTxVersion.v1 ? 1 : 0,
          chainId: chainId,
          entryPointSelectorName: "__execute__",
          nonce: nonce,
          useLegacyCalldata: useLegacyCalldata,
          maxFee: maxFee,
        );

        final calldata = functionCallsToCalldata(
          functionCalls: functionCalls,
          useLegacyCalldata: useLegacyCalldata,
        );

        return provider.addInvokeTransaction(
          InvokeTransactionRequest(
            invokeTransaction: InvokeTransactionV1(
              senderAddress: accountAddress,
              calldata: calldata,
              signature: signature,
              maxFee: maxFee,
              nonce: nonce,
            ),
          ),
        );
      case AccountSupportedTxVersion.v3:
        final signature = signer.signTransactions(
          transactions: functionCalls,
          contractAddress: accountAddress,
          version: supportedTxVersion == AccountSupportedTxVersion.v1 ? 1 : 0,
          chainId: chainId,
          entryPointSelectorName: "__execute__",
          nonce: nonce,
          useLegacyCalldata: useLegacyCalldata,
          maxFee: maxFee,
        );

        final calldata = functionCallsToCalldata(
          functionCalls: functionCalls,
          useLegacyCalldata: useLegacyCalldata,
        );

        return provider.addInvokeTransaction(
          InvokeTransactionRequest(
            invokeTransaction: InvokeTransactionV3(
              senderAddress: accountAddress,
              calldata: calldata,
              signature: signature,
              nonce: nonce,
              accountDeploymentData: [],
              feeDataAvailabilityMode: feeDataAvailabilityMode,
              nonceDataAvailabilityMode: nonceDataAvailabilityMode,
              paymasterData: [],
              resourceBounds: {},
              tip: Felt.fromHexString('0x0'), // 根据官方文档，目前总是0
            ),
          ),
        );
    }
  }

  /// Call account contract `__execute__` with given [functionCalls]
  Future<InvokeTransactionRequest> executeSignOnly({
    required List<FunctionCall> functionCalls,
    bool useLegacyCalldata = false,
    Felt? maxFee,
    Felt? nonce,
    String feeDataAvailabilityMode = 'L1',
    String nonceDataAvailabilityMode = 'L1',
  }) async {
    nonce = nonce ?? await getNonce();
    maxFee = maxFee ??
        await getEstimateMaxFeeForBraavosInvokeTx(
            nonce: nonce, functionCalls: functionCalls);

    final signature = signer.signTransactions(
      transactions: functionCalls,
      contractAddress: accountAddress,
      version: supportedTxVersion == AccountSupportedTxVersion.v1 ? 1 : 0,
      chainId: chainId,
      entryPointSelectorName: "__execute__",
      nonce: nonce,
      useLegacyCalldata: useLegacyCalldata,
      maxFee: maxFee,
    );

    switch (supportedTxVersion) {
      // ignore: deprecated_member_use_from_same_package
      case AccountSupportedTxVersion.v0:
        final calldata =
            functionCallsToCalldataLegacy(functionCalls: functionCalls) +
                [nonce];

        return InvokeTransactionRequest(
          invokeTransaction: InvokeTransactionV0(
            contractAddress: accountAddress,
            entryPointSelector: getSelectorByName('__execute__'),
            calldata: calldata,
            maxFee: maxFee,
            signature: signature,
          ),
        );
      case AccountSupportedTxVersion.v1:
        final calldata = functionCallsToCalldata(
          functionCalls: functionCalls,
          useLegacyCalldata: useLegacyCalldata,
        );

        return InvokeTransactionRequest(
          invokeTransaction: InvokeTransactionV1(
            senderAddress: accountAddress,
            calldata: calldata,
            signature: signature,
            maxFee: maxFee,
            nonce: nonce,
          ),
        );
      case AccountSupportedTxVersion.v3:
        final calldata = functionCallsToCalldata(
          functionCalls: functionCalls,
          useLegacyCalldata: useLegacyCalldata,
        );

        return InvokeTransactionRequest(
          invokeTransaction: InvokeTransactionV3(
            senderAddress: accountAddress,
            calldata: calldata,
            signature: signature,
            nonce: nonce,
            accountDeploymentData: [],
            feeDataAvailabilityMode: feeDataAvailabilityMode,
            nonceDataAvailabilityMode: nonceDataAvailabilityMode,
            paymasterData: [],
            resourceBounds: {},
            tip: Felt.fromHexString('0x0'), // 根据官方文档，目前总是0
          ),
        );
    }
  }

  /// Declares a [compiledContract]
  Future<DeclareTransactionResponse> declare({
    required ICompiledContract compiledContract,
    Felt? maxFee,
    Felt? nonce,
    // needed for v2
    BigInt? compiledClassHash,
    CASMCompiledContract? casmCompiledContract,
  }) async {
    nonce = nonce ?? await getNonce();
    maxFee = maxFee ??
        await getEstimateMaxFeeForDeclareTx(
            nonce: nonce, compiledContract: compiledContract);
    if (compiledContract is DeprecatedCompiledContract) {
      final signature = signer.signDeclareTransactionV1(
        compiledContract: compiledContract,
        senderAddress: accountAddress,
        chainId: chainId,
        nonce: nonce,
        maxFee: maxFee,
      );

      return provider.addDeclareTransaction(
        DeclareTransactionRequest(
          declareTransaction: DeclareTransactionV1(
            max_fee: maxFee,
            nonce: nonce,
            contractClass: compiledContract.compress(),
            senderAddress: accountAddress,
            signature: signature,
          ),
        ),
      );
    } else {
      final signature = signer.signDeclareTransactionV2(
        compiledContract: compiledContract as CompiledContract,
        senderAddress: accountAddress,
        chainId: chainId,
        nonce: nonce,
        compiledClassHash: compiledClassHash,
        casmCompiledContract: casmCompiledContract,
        maxFee: maxFee,
      );

      return provider.addDeclareTransaction(
        DeclareTransactionRequest(
          declareTransaction: DeclareTransactionV2(
            max_fee: maxFee,
            nonce: nonce,
            contractClass: compiledContract.flatten(),
            compiledClassHash: Felt(compiledClassHash!),
            senderAddress: accountAddress,
            signature: signature,
          ),
        ),
      );
    }
  }

  /// Deploys an instance of [classHash] with given [salt], [unique] and [calldata]
  ///
  /// Contract is deployed with UDC: https://docs.openzeppelin.com/contracts-cairo/0.6.1/udc
  /// Returns deployed contract address
  Future<Felt?> deploy({
    required Felt classHash,
    Felt? salt,
    Felt? unique,
    List<Felt>? calldata,
  }) async {
    salt ??= Felt.fromInt(0);
    unique ??= Felt.fromInt(0);
    calldata ??= [];

    final txHash = await Udc(account: this, address: udcAddress)
        .deployContract(classHash, salt, unique, calldata);

    final txReceipt = await account0.provider
        .getTransactionReceipt(Felt.fromHexString(txHash));

    return getDeployedContractAddress(txReceipt);
  }

  /// Get token balance of account
  Future<Uint256> balance() async =>
      ERC20(account: this, address: ethAddress).balanceOf(accountAddress);

  /// Sends [amount] of token to [recipient]
  ///
  /// Returns transaction hash
  Future<String> send({
    required Felt recipient,
    required Uint256 amount,
    required Felt erc20ContractAddress,
    required Felt maxFee,
  }) async {
    final txHash =
        await ERC20(account: this, address: erc20ContractAddress).transfer(
      recipient,
      amount,
      maxFee,
    );
    return txHash;
  }

  /// same as send but only sign
  Future<String> transferSign({
    required Felt recipient,
    required Uint256 amount,
    required Felt erc20ContractAddress,
    required Felt maxFee,
  }) async {
    final signed =
        await ERC20(account: this, address: erc20ContractAddress).transferSign(
      recipient,
      amount,
      maxFee,
    );
    return json.encode(signed.toJson());
  }

  /// Returns `true` if account is a valid one
  ///
  /// As a simple rule, we assume a contract is valid if class hash is not none
  Future<bool> get isValid async {
    final accountClassHash = (await provider.getClassHashAt(
      contractAddress: accountAddress,
      blockId: BlockId.latest,
    ))
        .when(
      result: (result) => result,
      error: ((error) => Felt.fromInt(0)),
    );
    return accountClassHash != Felt.fromInt(0);
  }

  /// Deploy an account with given [signer], [provider] and [constructorCalldata]
  ///
  /// Default value for [classHash] is [devnetOpenZeppelinAccountClassHash]
  /// Default value for [contractAddressSalt] is 42
  static Future<DeployAccountTransactionResponse> deployAccount({
    required Signer signer,
    required Provider provider,
    required List<Felt> constructorCalldata,
    required Felt classHash,
    Felt? contractAddressSalt,
    Felt? maxFee,
    Felt? nonce,
  }) async {
    final chainId = (await provider.chainId()).when(
      result: (result) => Felt.fromHexString(result),
      error: (error) => StarknetChainId.testNet,
    );

    maxFee = maxFee ?? defaultMaxFee;
    nonce = nonce ?? defaultNonce;
    contractAddressSalt = contractAddressSalt ?? signer.publicKey;

    final signature = signer.signDeployAccountTransactionV1(
      contractAddressSalt: contractAddressSalt,
      classHash: classHash,
      constructorCalldata: constructorCalldata,
      chainId: chainId,
      nonce: nonce,
      maxFee: maxFee,
    );
    return provider.addDeployAccountTransaction(
      DeployAccountTransactionRequest(
        deployAccountTransaction: DeployAccountTransactionV1(
          classHash: classHash,
          signature: signature,
          maxFee: maxFee,
          nonce: nonce,
          contractAddressSalt: contractAddressSalt,
          constructorCalldata: constructorCalldata,
        ),
      ),
    );
  }

  static Future<DeployAccountTransactionResponse> deployArgentAccount({
    required Signer signer,
    required Provider provider,
    required List<Felt> constructorCalldata,
    required Felt classHash,
    required Felt address,
    required String version,
    Felt? contractAddressSalt,
    Felt? maxFee,
    Felt? nonce,
    Felt? gas,
    Felt? gasPrice,
  }) async {
    final chainId = (await provider.chainId()).when(
      result: (result) => Felt.fromHexString(result),
      error: (error) => StarknetChainId.testNet,
    );

    nonce = nonce ?? defaultNonce;
    contractAddressSalt = contractAddressSalt ?? signer.publicKey;

    if (version == '0x1') {
      // v1 部署时 这个费用一定会存在
      assert(maxFee != null);

      final signature = signer.signArgentDeployAccountTransactionV1(
        contractAddressSalt: contractAddressSalt,
        classHash: classHash,
        constructorCalldata: constructorCalldata,
        chainId: chainId,
        nonce: nonce,
        maxFee: maxFee,
      );

      return provider.addDeployAccountTransaction(
        DeployAccountTransactionRequest(
          deployAccountTransaction: DeployAccountTransactionV1(
            classHash: classHash,
            signature: signature,
            maxFee: maxFee!,
            nonce: nonce,
            contractAddressSalt: contractAddressSalt,
            constructorCalldata: constructorCalldata,
          ),
        ),
      );
    } else {
      // v3 部署时 这两个费用一定会存在
      assert(gas != null);
      assert(gasPrice != null);

      final signature = signer.signArgentDeployAccountTransactionV3(
        address: address,
        contractAddressSalt: contractAddressSalt,
        classHash: classHash,
        constructorCalldata: constructorCalldata,
        chainId: chainId,
        nonce: nonce,
        version: Felt.fromHexString(version),
        gas: gas!,
        gasPrice: gasPrice!,
      );

      return provider.addDeployAccountTransaction(
        DeployAccountTransactionRequest(
          deployAccountTransaction: DeployAccountTransactionV3(
            classHash: classHash,
            signature: signature,
            nonce: nonce,
            contractAddressSalt: contractAddressSalt,
            constructorCalldata: constructorCalldata,
            tip: Felt.fromHexString('0x0'),
            feeDataAvailabilityMode: 'L1',
            nonceDataAvailabilityMode: 'L1',
            paymasterData: [],
            resourceBounds: {
              "l1_gas": {
                "max_amount": gas.toHexString(),
                "max_price_per_unit": gasPrice.toHexString()
              },
              "l2_gas": {"max_amount": "0x0", "max_price_per_unit": "0x0"}
            },
          ),
        ),
      );
    }
  }

  static Future<String> signDeployArgentAccount({
    required Signer signer,
    required Provider provider,
    required List<Felt> constructorCalldata,
    required Felt classHash,
    Felt? contractAddressSalt,
    Felt? maxFee,
    Felt? nonce,
  }) async {
    final chainId = (await provider.chainId()).when(
      result: (result) => Felt.fromHexString(result),
      error: (error) => StarknetChainId.testNet,
    );

    maxFee = maxFee ?? defaultMaxFee;
    nonce = nonce ?? defaultNonce;
    contractAddressSalt = contractAddressSalt ?? signer.publicKey;

    final signature = signer.signArgentDeployAccountTransactionV1(
      contractAddressSalt: contractAddressSalt,
      classHash: classHash,
      constructorCalldata: constructorCalldata,
      chainId: chainId,
      nonce: nonce,
      maxFee: maxFee,
    );

    final request = DeployAccountTransactionRequest(
        deployAccountTransaction: DeployAccountTransactionV1(
      classHash: classHash,
      signature: signature,
      maxFee: maxFee,
      nonce: nonce,
      contractAddressSalt: contractAddressSalt,
      constructorCalldata: constructorCalldata,
    ));

    return jsonEncode(request.toJson());
  }

  static Future<DeployAccountTransactionResponse> deployBraavosAccount({
    required Signer signer,
    required Provider provider,
    required List<Felt> constructorCalldata,
    required Felt classHash,
    required Felt baseClassHash,
    Felt? contractAddressSalt,
    Felt? maxFee,
    Felt? nonce,
  }) async {
    final chainId = (await provider.chainId()).when(
      result: (result) => Felt.fromHexString(result),
      error: (error) => StarknetChainId.testNet,
    );

    maxFee = maxFee ?? defaultMaxFee;
    nonce = nonce ?? defaultNonce;
    contractAddressSalt = contractAddressSalt ?? signer.publicKey;

    final signature = signer.signBraavosDeployAccountTransactionV1(
      contractAddressSalt: contractAddressSalt,
      classHash: classHash,
      baseClassHash: baseClassHash,
      constructorCalldata: constructorCalldata,
      chainId: chainId,
      nonce: nonce,
      maxFee: maxFee,
    );

    return provider.addDeployAccountTransaction(
      DeployAccountTransactionRequest(
        deployAccountTransaction: DeployAccountTransactionV1(
          classHash: baseClassHash,
          signature: signature,
          maxFee: maxFee,
          nonce: nonce,
          contractAddressSalt: contractAddressSalt,
          constructorCalldata: constructorCalldata,
        ),
      ),
    );
  }

  static Future<String> signDeployBraavosAccount({
    required Signer signer,
    required Provider provider,
    required List<Felt> constructorCalldata,
    required Felt classHash,
    required Felt baseClassHash,
    Felt? contractAddressSalt,
    Felt? maxFee,
    Felt? nonce,
  }) async {
    final chainId = (await provider.chainId()).when(
      result: (result) => Felt.fromHexString(result),
      error: (error) => StarknetChainId.testNet,
    );

    maxFee = maxFee ?? defaultMaxFee;
    nonce = nonce ?? defaultNonce;
    contractAddressSalt = contractAddressSalt ?? signer.publicKey;

    final signature = signer.signBraavosDeployAccountTransactionV1(
      contractAddressSalt: contractAddressSalt,
      classHash: classHash,
      baseClassHash: baseClassHash,
      constructorCalldata: constructorCalldata,
      chainId: chainId,
      nonce: nonce,
      maxFee: maxFee,
    );
    final request = DeployAccountTransactionRequest(
      deployAccountTransaction: DeployAccountTransactionV1(
        classHash: baseClassHash,
        signature: signature,
        maxFee: maxFee,
        nonce: nonce,
        contractAddressSalt: contractAddressSalt,
        constructorCalldata: constructorCalldata,
      ),
    );
    return json.encode(request.toJson());
  }

  /// Retrieves an account from given [mnemonic], [provider] and [chainId]
  ///
  /// Default [accountDerivation] is [BraavosAccountDerivation]
  factory Account.fromMnemonic({
    required String mnemonic,
    required Provider provider,
    required Felt chainId,
    int index = 0,
    AccountDerivation? accountDerivation,
  }) {
    accountDerivation = accountDerivation ??
        BraavosAccountDerivation(
          provider: provider,
          chainId: chainId,
        );
    final signer =
        accountDerivation.deriveSigner(mnemonic: mnemonic, index: index);

    final accountAddress =
        accountDerivation.computeAddress(publicKey: signer.publicKey);
    return Account(
      accountAddress: accountAddress,
      provider: provider,
      signer: signer,
      chainId: chainId,
    );
  }
}

Account getAccount({
  required Felt accountAddress,
  required Felt privateKey,
  Uri? nodeUri,
  Felt? chainId,
}) {
  nodeUri ??= devnetUri;
  chainId ??= StarknetChainId.testNet;

  final provider = JsonRpcProvider(nodeUri: nodeUri);
  final signer = Signer(privateKey: privateKey);

  return Account(
    provider: provider,
    signer: signer,
    accountAddress: accountAddress,
    chainId: chainId,
  );
}

/// Get deployed contract address from [txReceipt]
Felt? getDeployedContractAddress(GetTransactionReceipt txReceipt) {
  return txReceipt.when(
    result: (r) {
      for (var event in r.events) {
        // contract constructor can generate some event also
        if (event.fromAddress == udcAddress) {
          return event.data?[0];
        }
      }
      throw Exception("UDC deployer event not found");
    },
    error: (e) => throw Exception(e.message),
  );
}

/// Account derivation interface
abstract class AccountDerivation {
  /// Derive [Signer] from given [mnemonic] and [index]
  Signer deriveSigner({required String mnemonic, int index = 0});

  /// Returns expected constructor call data
  List<Felt> constructorCalldata({required Felt publicKey});

  /// Returns account address from given [publicKey]
  Felt computeAddress({required Felt publicKey});
}

class OpenzeppelinAccountDerivation implements AccountDerivation {
  late final Felt proxyClassHash;
  late final Felt implementationClassHash;

  OpenzeppelinAccountDerivation({
    Felt? proxyClassHash,
    Felt? implementationClassHash,
  }) {
    this.proxyClassHash = proxyClassHash ?? ozProxyClassHash;
    this.implementationClassHash =
        implementationClassHash ?? ozAccountUpgradableClassHash;
  }

  @override
  Signer deriveSigner({required String mnemonic, int index = 0}) {
    final privateKey = derivePrivateKey(mnemonic: mnemonic, index: index);
    return Signer(privateKey: privateKey);
  }

  @override
  Felt computeAddress({required Felt publicKey}) {
    final calldata = constructorCalldata(publicKey: publicKey);
    final salt = publicKey;
    final accountAddress = Contract.computeAddress(
      classHash: proxyClassHash,
      calldata: calldata,
      salt: salt,
    );
    return accountAddress;
  }

  @override
  List<Felt> constructorCalldata({required Felt publicKey}) {
    return [
      implementationClassHash,
      getSelectorByName("initializer"),
      Felt.fromInt(1),
      publicKey
    ];
  }

  Future<Felt> deploy({required Account account}) async {
    final tx = await Account.deployAccount(
      signer: account.signer,
      provider: account.provider,
      constructorCalldata: constructorCalldata(
        publicKey: account.signer.publicKey,
      ),
      classHash: proxyClassHash,
      contractAddressSalt: account.signer.publicKey,
    );
    final deployTxHash = tx.when(
      result: (result) {
        print(
          "Account is deployed at ${result.contractAddress.toHexString()} (tx: ${result.transactionHash.toHexString()})",
        );
        return result.transactionHash;
      },
      error: (error) {
        throw Exception(
          "Account deploy failed: ${error.code} ${error.message}",
        );
      },
    );
    return deployTxHash;
  }
}

/// Account derivation used by Braavos account
/// refactor according to https://github.com/xJonathanLEI/starknet-rs
class BraavosAccountDerivation extends AccountDerivation {
  final Provider provider;
  final Felt chainId;

  // update according https://github.com/myBraavos/braavos-account-cairo
  static final classHash = Felt.fromHexString(
    "0x00816dd0297efc55dc1e7559020a3a825e81ef734b558f03c83325d4da7e6253",
  );

  // update according https://github.com/myBraavos/braavos-account-cairo
  static final baseClassHash = Felt.fromHexString(
    "0x013bfe114fb1cf405bfc3a7f8dbe2d91db146c17521d40dcf57e16d6b59fa8e6",
  );
  final initializerSelector = getSelectorByName("initializer");

  BraavosAccountDerivation({
    required this.provider,
    required this.chainId,
  });

  static Map<String, Uint8List> getExtendedPrivateKey(String mnemonic) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final nodeFromSeed = bip32.BIP32.fromSeed(seed);

    return {
      "key": nodeFromSeed.privateKey!,
      "chainCode": nodeFromSeed.chainCode,
    };
  }

  static AccountInfo getAccountInfoFromMnemonic(String mnemonic, int index) {
    final privateKey = derivePrivateKey(mnemonic: mnemonic, index: index);
    final signer = Signer(privateKey: privateKey);

    final accountAddress = Contract.computeAddress(
      classHash: baseClassHash,
      calldata: [signer.publicKey],
      salt: signer.publicKey,
    );
    return AccountInfo(
      privateKey,
      signer.publicKey,
      accountAddress,
    );
  }

  static AccountInfo getAccountInfoFromExtendedPrivateKey(
      Uint8List chainKey, Uint8List chainCode, int index) {
    final node = bip32.BIP32.fromPrivateKey(chainKey, chainCode);

    final child = node.derivePath("m/44'/9004'/0'/0/$index");
    Uint8List key = child.privateKey!;
    key = grindKey(key);
    final privateKey = Felt(bytesToUnsignedInt(key));
    final signer = Signer(privateKey: privateKey);
    final accountAddress = Contract.computeAddress(
      classHash: baseClassHash,
      calldata: [signer.publicKey],
      salt: signer.publicKey,
    );
    return AccountInfo(
      privateKey,
      signer.publicKey,
      accountAddress,
    );
  }

  @override
  Signer deriveSigner({required String mnemonic, int index = 0}) {
    final privateKey = derivePrivateKey(mnemonic: mnemonic, index: index);
    return Signer(privateKey: privateKey);
  }

  @override
  List<Felt> constructorCalldata({required Felt publicKey}) {
    return [publicKey];
  }

  Future<Felt> deploy({required Account account, required Felt maxFee}) async {
    final tx = await Account.deployBraavosAccount(
      signer: account.signer,
      provider: account.provider,
      constructorCalldata: constructorCalldata(
        publicKey: account.signer.publicKey,
      ),
      classHash: classHash,
      baseClassHash: baseClassHash,
      contractAddressSalt: account.signer.publicKey,
      nonce: Felt.fromInt(0),
      maxFee: maxFee,
    );
    final deployTxHash = tx.when(
      result: (result) {
        print(
          "Account is deployed at ${result.contractAddress.toHexString()} (tx: ${result.transactionHash.toHexString()})",
        );
        return result.transactionHash;
      },
      error: (error) {
        throw Exception(
          "Account deploy failed: ${error.code} ${error.message}",
        );
      },
    );
    return deployTxHash;
  }

  Future<String> deploySigned(
      {required Account account, required Felt maxFee}) async {
    final signed = await Account.signDeployBraavosAccount(
      signer: account.signer,
      provider: account.provider,
      constructorCalldata: constructorCalldata(
        publicKey: account.signer.publicKey,
      ),
      classHash: classHash,
      baseClassHash: baseClassHash,
      contractAddressSalt: account.signer.publicKey,
      nonce: Felt.fromInt(0),
      maxFee: maxFee,
    );

    return signed;
  }

  @override
  Felt computeAddress({required Felt publicKey}) {
    final calldata = constructorCalldata(publicKey: publicKey);
    final salt = publicKey;
    final accountAddress = Contract.computeAddress(
      classHash: baseClassHash,
      calldata: calldata,
      salt: salt,
    );
    return accountAddress;
  }
}

class ArgentXAccountDerivation extends AccountDerivation {
  final Provider provider;
  final Felt chainId;

  ArgentXAccountDerivation({
    required this.provider,
    required this.chainId,
  });

  static final String masterPrefix = "m/44'/60'/0'/0/0";
  static final String pathPrefix = "m/44'/9004'/0'/0";

  static final classHash = Felt.fromHexString(
    "0x036078334509b514626504edc9fb252328d1a240e4e948bef8d0c08dff45927f",
  );

  static Map<String, Uint8List> getExtendedPrivateKey(String mnemonic) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final hdNodeSingleSeed = bip32.BIP32.fromSeed(seed);
    final hdNodeDoubleSeed = bip32.BIP32
        .fromSeed(hdNodeSingleSeed.derivePath(masterPrefix).privateKey!);

    return {
      "key": hdNodeDoubleSeed.privateKey!,
      "chainCode": hdNodeDoubleSeed.chainCode,
    };
  }

  Future<Felt> deploy({
    required Account account,
    Felt? maxFee,
    required String version,
    Felt? gas,
    Felt? gasPrice,
  }) async {
    final tx = await Account.deployArgentAccount(
      signer: account.signer,
      provider: account.provider,
      constructorCalldata: constructorCalldata(
        publicKey: account.signer.publicKey,
      ),
      classHash: classHash,
      contractAddressSalt: account.signer.publicKey,
      nonce: Felt.fromInt(0),
      maxFee: maxFee,
      version: version,
      gasPrice: gasPrice,
      gas: gas,
      address: account.accountAddress,
    );
    final deployTxHash = tx.when(
      result: (result) {
        return result.transactionHash;
      },
      error: (error) {
        throw Exception(
          "Account deploy failed: ${error.code} ${error.message}",
        );
      },
    );
    return deployTxHash;
  }

  Future<String> deploySigned({
    required Account account,
    required Felt maxFee,
  }) async {
    final request = await Account.signDeployArgentAccount(
      signer: account.signer,
      provider: account.provider,
      constructorCalldata: constructorCalldata(
        publicKey: account.signer.publicKey,
      ),
      classHash: classHash,
      contractAddressSalt: account.signer.publicKey,
      nonce: Felt.fromInt(0),
      maxFee: maxFee,
    );

    return request;
  }

  static AccountInfo getAccountInfoFromMnemonic(String mnemonic,
      {int index = 0}) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final hdNodeSingleSeed = bip32.BIP32.fromSeed(seed);
    final hdNodeDoubleSeed = bip32.BIP32
        .fromSeed(hdNodeSingleSeed.derivePath(masterPrefix).privateKey!);
    final child = hdNodeDoubleSeed.derivePath('$pathPrefix/$index');
    Uint8List key = child.privateKey!;
    key = grindKey(key);
    final privateKey = Felt(bytesToUnsignedInt(key));
    final signer = Signer(privateKey: privateKey);
    final accountAddress = Contract.computeAddress(
      classHash: classHash,
      calldata: [
        Felt.fromInt(0),
        signer.publicKey,
        Felt.fromInt(1),
      ],
      salt: signer.publicKey,
    );
    return AccountInfo(
      privateKey,
      signer.publicKey,
      accountAddress,
    );
  }

  @override
  Signer deriveSigner({required String mnemonic, int index = 0}) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final hdNodeSingleSeed = bip32.BIP32.fromSeed(seed);
    final hdNodeDoubleSeed = bip32.BIP32
        .fromSeed(hdNodeSingleSeed.derivePath(masterPrefix).privateKey!);
    final child = hdNodeDoubleSeed.derivePath('$pathPrefix/$index');
    Uint8List key = child.privateKey!;
    key = grindKey(key);
    final privateKey = Felt(bytesToUnsignedInt(key));
    return Signer(privateKey: privateKey);
  }

  @override
  List<Felt> constructorCalldata({required Felt publicKey}) {
    /// 项目方反应 0.4.0账户的calldata有变动， 对应到dart则是以下值
    ///const ownerSigner = new CairoCustomEnum({
    ///     Starknet: { signer: ownerPubKey },
    ///     Secp256k1: undefined,
    ///     Secp256r1: undefined,
    ///     Eip191: undefined,
    ///     Webauthn: undefined,
    /// });
    ///
    /// const guardian = new CairoOption(CairoOptionVariant.None);
    ///
    /// const calculatedAddress = hash.calculateContractAddressFromHash(
    ///   ownerPubKey, // salt
    ///   classHash,
    ///   CallData.compile({ owner: ownerSigner, guardian }), // constructor calldata
    ///   0 // deployer address
    /// );
    return [
      Felt.fromInt(0),
      publicKey,
      Felt.fromInt(1),
    ];
  }

  static AccountInfo getAccountInfoFromExtendedPrivateKey(
      Uint8List chainKey, Uint8List chainCode, int index) {
    final node = bip32.BIP32.fromPrivateKey(chainKey, chainCode);
    final child = node.derivePath("$pathPrefix/$index");
    Uint8List key = child.privateKey!;
    key = grindKey(key);
    final privateKey = Felt(bytesToUnsignedInt(key));
    final signer = Signer(privateKey: privateKey);
    final accountAddress = Contract.computeAddress(
      classHash: classHash,
      calldata: [
        Felt.fromInt(0),
        signer.publicKey,
        Felt.fromInt(1),
      ],
      salt: signer.publicKey,
    );
    return AccountInfo(
      privateKey,
      signer.publicKey,
      accountAddress,
    );
  }

  static AccountInfo getAccountInfoFromPrivateKey(Uint8List privateKey) {
    final priKey = Felt(bytesToUnsignedInt(privateKey));
    final signer = Signer(privateKey: priKey);
    final accountAddress = Contract.computeAddress(
      classHash: classHash,
      calldata: [
        Felt.fromInt(0),
        signer.publicKey,
        Felt.fromInt(1),
      ],
      salt: signer.publicKey,
    );
    return AccountInfo(
      priKey,
      signer.publicKey,
      accountAddress,
    );
  }

  @override
  Felt computeAddress({required Felt publicKey}) {
    final calldata = constructorCalldata(publicKey: publicKey);
    final salt = publicKey;
    final accountAddress = Contract.computeAddress(
      classHash: classHash,
      calldata: calldata,
      salt: salt,
    );
    return accountAddress;
  }

  static Future<DeployAccountTransactionResponse> deployAccount({
    required Signer signer,
    required Provider provider,
    required List<Felt> constructorCalldata,
    required Felt classHash,
    required Felt baseClassHash,
    Felt? contractAddressSalt,
    Felt? maxFee,
    Felt? nonce,
  }) async {
    final chainId = (await provider.chainId()).when(
      result: (result) => Felt.fromHexString(result),
      error: (error) => StarknetChainId.testNet,
    );

    maxFee = maxFee ?? defaultMaxFee;
    nonce = nonce ?? defaultNonce;
    contractAddressSalt = contractAddressSalt ?? signer.publicKey;

    final signature = signer.signBraavosDeployAccountTransactionV1(
      contractAddressSalt: contractAddressSalt,
      classHash: classHash,
      baseClassHash: baseClassHash,
      constructorCalldata: constructorCalldata,
      chainId: chainId,
      nonce: nonce,
      maxFee: maxFee,
    );

    return provider.addDeployAccountTransaction(
      DeployAccountTransactionRequest(
        deployAccountTransaction: DeployAccountTransactionV1(
          classHash: baseClassHash,
          signature: signature,
          maxFee: maxFee,
          nonce: nonce,
          contractAddressSalt: contractAddressSalt,
          constructorCalldata: constructorCalldata,
        ),
      ),
    );
  }
}
