// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starknet/starknet.dart';

part 'deploy_account_transaction.freezed.dart';
part 'deploy_account_transaction.g.dart';

abstract class DeployAccountTransaction {
  factory DeployAccountTransaction.fromJson(Map<String, Object?> json) =>
      json['version'] == '0x01'
          ? DeployAccountTransaction.fromJson(json)
          : throw Exception("Unsupported version ${json['version']}");

  Map<String, dynamic> toJson();
}

@freezed
class DeployAccountTransactionV1
    with _$DeployAccountTransactionV1
    implements DeployAccountTransaction {
  const factory DeployAccountTransactionV1({
    required List<Felt> signature,
    @JsonKey(toJson: maxFeeToJson) required Felt maxFee,
    required Felt nonce,
    required Felt contractAddressSalt,
    required List<Felt> constructorCalldata,
    required Felt classHash,
    @Default('0x01') String version,
    @Default('DEPLOY_ACCOUNT') String type,
  }) = _DeployAccountTransactionV1;

  factory DeployAccountTransactionV1.fromJson(Map<String, Object?> json) =>
      _$DeployAccountTransactionV1FromJson(json);
}

@freezed
class DeployAccountTransactionV3
    with _$DeployAccountTransactionV3
    implements DeployAccountTransaction {
  const factory DeployAccountTransactionV3({

    required List<Felt> signature,
    required Felt contractAddressSalt,
    required List<Felt> constructorCalldata,
    required Felt nonce,
    required Felt tip,
    required Felt classHash,
    required String feeDataAvailabilityMode,
    required String nonceDataAvailabilityMode,
    required List<Felt> paymasterData,
    required Map<String, dynamic> resourceBounds,

    @Default('0x3') String version,
    @Default('DEPLOY_ACCOUNT') String type,
  }) = _DeployAccountTransactionV3;

  factory DeployAccountTransactionV3.fromJson(Map<String, Object?> json) =>
      _$DeployAccountTransactionV3FromJson(json);
}

@freezed
class DeployAccountTransactionRequest with _$DeployAccountTransactionRequest {
  const factory DeployAccountTransactionRequest({
    required DeployAccountTransaction deployAccountTransaction,
  }) = _DeployAccountTransactionRequest;

  factory DeployAccountTransactionRequest.fromJson(Map<String, Object?> json) =>
      _$DeployAccountTransactionRequestFromJson(json);
}

@freezed
class DeployAccountTransactionResponse with _$DeployAccountTransactionResponse {
  const factory DeployAccountTransactionResponse.result({
    required DeployAccountTransactionResponseResult result,
  }) = DeployAccountTransactionResult;
  const factory DeployAccountTransactionResponse.error({
    required JsonRpcApiError error,
  }) = DeployAccountTransactionError;

  factory DeployAccountTransactionResponse.fromJson(
          Map<String, Object?> json) =>
      json.containsKey('error')
          ? DeployAccountTransactionError.fromJson(json)
          : DeployAccountTransactionResult.fromJson(json);
}

@freezed
class DeployAccountTransactionResponseResult
    with _$DeployAccountTransactionResponseResult {
  const factory DeployAccountTransactionResponseResult({
    required Felt transactionHash,
    required Felt contractAddress,
  }) = _DeployAccountTransactionResponseResult;

  factory DeployAccountTransactionResponseResult.fromJson(
          Map<String, Object?> json) =>
      _$DeployAccountTransactionResponseResultFromJson(json);
}
