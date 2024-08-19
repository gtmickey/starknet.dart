// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starknet/starknet.dart';

part 'get_transaction.freezed.dart';
part 'get_transaction.g.dart';

@freezed
class GetTransaction with _$GetTransaction {
  const factory GetTransaction.result({
    required Txn result,
  }) = GetTransactionResult;
  const factory GetTransaction.error({
    required JsonRpcApiError error,
  }) = GetTransactionError;

  factory GetTransaction.fromJson(Map<String, Object?> json) =>
      json.containsKey('error')
          ? GetTransactionError.fromJson(json)
          : GetTransactionResult.fromJson(json);
}

@freezed
class Txn with _$Txn {
  const factory Txn.invokeTxnV0({
    // start of COMMON_TXN_PROPERTIES
    required Felt? transactionHash,

    // start of BROADCASTED_TXN_COMMON_PROPERTIES
    @JsonKey(toJson: maxFeeToJson) required Felt? maxFee,
    required String? version,
    required List<Felt>? signature,
    required Felt? nonce,
    required String? type,
    // end of BROADCASTED_TXN_COMMON_PROPERTIES
    // end of COMMON_TXN_PROPERTIES

    // start of INVOKE_TXN_V0
    required Felt? contractAddress,
    required Felt? entryPointSelector,
    required List<Felt>? calldata,
    // end of INVOKE_TXN_V0
  }) = InvokeTxnV0;

  const factory Txn.invokeTxnV1({
    // start of COMMON_TXN_PROPERTIES
    required Felt? transactionHash,
    // start of BROADCASTED_TXN_COMMON_PROPERTIES
    @JsonKey(toJson: maxFeeToJson) required Felt? maxFee,
    required String? version,
    required List<Felt>? signature,
    required Felt? nonce,
    required String? type,
    // end of BROADCASTED_TXN_COMMON_PROPERTIES
    // end of COMMON_TXN_PROPERTIES

    // start of INVOKE_TXN_V1
    required Felt? sender_address,
    required List<Felt>? calldata,
    // end of INVOKE_TXN_V1
  }) = InvokeTxnV1;

  const factory Txn.declareTxn({
    // start of COMMON_TXN_PROPERTIES
    required Felt? transactionHash,
    // start of BROADCASTED_TXN_COMMON_PROPERTIES
    @JsonKey(toJson: maxFeeToJson) required Felt? maxFee,
    required String? version,
    required List<Felt>? signature,
    required Felt? nonce,
    required String? type,
    // end of BROADCASTED_TXN_COMMON_PROPERTIES
    // end of COMMON_TXN_PROPERTIES

    required Felt? classHash,
    required Felt? senderAddress,
  }) = DeclareTxn;

  const factory Txn.deployTxn({
    required Felt? transactionHash,
    required Felt? classHash,

    // start of DEPLOY_TXN_PROPERTIES
    required String? version,
    required String? type,
    required Felt? contractAddressSalt,
    required List<Felt>? constructorCalldata,
    // end of DEPLOY_TXN_PROPERTIES
  }) = DeployTxn;

  const factory Txn.deployAccountTxn({
    // start of COMMON_TXN_PROPERTIES
    required Felt? transactionHash,
    // start of BROADCASTED_TXN_COMMON_PROPERTIES
    @JsonKey(toJson: maxFeeToJson) required Felt? maxFee,
    required String? version,
    required List<Felt>? signature,
    required Felt? nonce,
    required String? type,
    // end of BROADCASTED_TXN_COMMON_PROPERTIES
    // end of COMMON_TXN_PROPERTIES

    // start of DEPLOY_ACCOUNT_TXN_PROPERTIES
    required Felt? contractAddressSalt,
    required Felt? classHash,
    required List<Felt>? constructorCalldata,
    // end of DEPLOY_ACCOUNT_TXN_PROPERTIES
  }) = DeployAccountTxn;

  const factory Txn.l1HandlerTxn({
    required Felt? transactionHash,
    required String? version,
    required Felt? nonce,
    required String? type,

    // start of FUNCTION_CALL
    required Felt? contractAddress,
    required Felt? entryPointSelector,
    required List<Felt>? calldata,
    // end of FUNCTION_CALL
  }) = L1HandlerTxn;

  // TODO: The json response doesn't have type attribute.
  factory Txn.fromJson(Map<String, Object?> json) => json['type'] == 'DECLARE'
      ? DeclareTxn.fromJson(json)
      : json['type'] == 'DEPLOY'
          ? DeployTxn.fromJson(json)
          : json['type'] == 'INVOKE'
              ? json['version'] == '0x1'
                  ? InvokeTxnV1.fromJson(json)
                  : InvokeTxnV0.fromJson(json)
              : json['type'] == 'DEPLOY_ACCOUNT'
                  ? DeployAccountTxn.fromJson(json)
                  : L1HandlerTxn.fromJson(json);
}
