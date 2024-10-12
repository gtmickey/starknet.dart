// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:starknet/starknet.dart';

part 'estimate_fee.freezed.dart';

part 'estimate_fee.g.dart';

@freezed
class EstimateFee with _$EstimateFee {
  const factory EstimateFee.result({
    required List<FeeEstimate> result,
  }) = EstimateFeeResult;

  const factory EstimateFee.error({
    required JsonRpcApiError error,
  }) = EstimateFeeError;

  factory EstimateFee.fromJson(Map<String, Object?> json) =>
      json.containsKey('error')
          ? EstimateFeeError.fromJson(json)
          : EstimateFeeResult.fromJson(json);
}

/// Flags that indicate how to simulate a given transaction.
/// By default, the sequencer behavior is replicated locally (enough funds are expected to be in the
/// account, and fee will be deducted from the balance before the simulation of the next
/// transaction). To skip the fee charge, use the SKIP_FEE_CHARGE flag.
@freezed
class SimulationFlag with _$SimulationFlag {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SimulationFlag.skipValidate() = SkipValidate;

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SimulationFlag.skipFeeCharge() = SkipFeeCharge;

  factory SimulationFlag.fromJson(Map<String, dynamic> json) =>
      _$SimulationFlagFromJson(json);

  Map<String, dynamic> toJson() => {
        'type': this.when(
          skipValidate: () => "SKIP_VALIDATE",
          skipFeeCharge: () => "SKIP_FEE_CHARGE",
        ),
      };
}

@JsonSerializable()
class EstimateFeeRequest {
  final List<BroadcastedTxn> request;
  final BlockId blockId;
  final List<SimulationFlag> simulation_flags;

  EstimateFeeRequest({
    required this.request,
    required this.blockId,
    required this.simulation_flags,
  });

  factory EstimateFeeRequest.fromJson(Map<String, dynamic> json) =>
      _$EstimateFeeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EstimateFeeRequestToJson(this);
}

@freezed
class BroadcastedTxn with _$BroadcastedTxn {
  @JsonSerializable(includeIfNull: false)
  const factory BroadcastedTxn.broadcastedInvokeTxnV0({
    // start of BROADCASTED_TXN_COMMON_PROPERTIES
    required String type,
    @JsonKey(toJson: maxFeeToJson) required Felt maxFee,
    required String version,
    required List<Felt> signature,
    Felt? nonce,
    // end of BROADCASTED_TXN_COMMON_PROPERTIES

    // start of INVOKE_TXN_V0
    required Felt contractAddress,
    required Felt entryPointSelector,
    required List<Felt> calldata,
    // end of INVOKE_TXN_V0
  }) = BroadcastedInvokeTxnV0;

  @JsonSerializable(includeIfNull: false)
  const factory BroadcastedTxn.broadcastedInvokeTxnV1({
    // start of BROADCASTED_TXN_COMMON_PROPERTIES
    required String type,
    @JsonKey(toJson: maxFeeToJson) required Felt maxFee,
    required String version,
    required List<Felt> signature,
    required Felt nonce,
    // end of BROADCASTED_TXN_COMMON_PROPERTIES

    // start of INVOKE_TXN_V1
    required Felt senderAddress,
    required List<Felt> calldata,
    // end of INVOKE_TXN_V1
  }) = BroadcastedInvokeTxnV1;

  @JsonSerializable(includeIfNull: false)
  const factory BroadcastedTxn.broadcastedInvokeTxnV3({
    // For future use.
    // Currently this value is always empty.
    required List<Felt> accountDeploymentData,
    required List<Felt> calldata,
    // For future use. Currently this value is always 0.
    required String feeDataAvailabilityMode,
    required Felt nonce,
    // For future use. Currently this value is always 0.
    required String nonceDataAvailabilityMode,
    // For future use. Currently this value is always empty.
    required List<Felt> paymasterData,
    required Map<String, dynamic> resourceBounds,
    required Felt senderAddress,
    required List<Felt> signature,

    // For future use. Currently this value is always 0.
    required Felt tip,
    required String version,
    required String type,
  }) = BroadcastedInvokeTxnV3;

  @JsonSerializable(includeIfNull: false)
  const factory BroadcastedTxn.broadcastedDeclareTxn({
    // start of BROADCASTED_TXN_COMMON_PROPERTIES
    required String type,
    @JsonKey(toJson: maxFeeToJson) required Felt maxFee,
    required String version,
    required List<Felt> signature,
    required Felt nonce,
    // end of BROADCASTED_TXN_COMMON_PROPERTIES

    required DeprecatedContractClass contractClass,
    required Felt senderAddress,
  }) = BroadcastedDeclareTxn;

  @JsonSerializable(includeIfNull: false)
  const factory BroadcastedTxn.broadcastedDeployTxn({
    required DeprecatedContractClass contractClass,
    // start of DEPLOY_TXN_PROPERTIES
    required String version,
    required String type,
    required Felt contractAddressSalt,
    required List<Felt> constructorCalldata,
    // end of DEPLOY_TXN_PROPERTIES
  }) = BroadcastedDeployTxn;

  @JsonSerializable(includeIfNull: false)
  const factory BroadcastedTxn.broadcastedDeployAccountTxn({
    required Felt contractAddressSalt,
    required Felt classHash,
    required List<Felt> constructorCalldata,

    // start of BROADCASTED_TXN_COMMON_PROPERTIES
    required String type,
    @JsonKey(toJson: maxFeeToJson) required Felt maxFee,
    required String version,
    required List<Felt> signature,
    required Felt nonce,
    // end of BROADCASTED_TXN_COMMON_PROPERTIES
  }) = BroadcastedDeployAccountTxn;

  @JsonSerializable(includeIfNull: false)
  const factory BroadcastedTxn.broadcastedDeployAccountTxnV3({
    required Felt contractAddressSalt,
    required Felt classHash,
    required List<Felt> constructorCalldata,
    required String
        feeDataAvailabilityMode, // For future use. Currently this value is always 0.
    required String
        nonceDataAvailabilityMode, // For future use. Currently this value is always 0.
    required List<Felt>
        paymasterData, // For future use. Currently this value is always empty.

    required Map<String, dynamic> resourceBounds,
    required Felt tip, // For future use. Currently this value is always 0.

    // start of BROADCASTED_TXN_COMMON_PROPERTIES
    required String type,
    required String version,
    required List<Felt> signature,
    required Felt nonce,
    // end of BROADCASTED_TXN_COMMON_PROPERTIES
  }) = BroadcastedDeployAccountTxnV3;

  factory BroadcastedTxn.fromJson(Map<String, Object?> json) =>
      json['type'] == 'DECLARE'
          ? BroadcastedDeclareTxn.fromJson(json)
          : json['type'] == 'DEPLOY'
              ? BroadcastedDeployTxn.fromJson(json)
              : json['type'] == 'INVOKE'
                  ? json['version'] == '0x1'
                      ? BroadcastedInvokeTxnV1.fromJson(json)
                      : BroadcastedInvokeTxnV0.fromJson(json)
                  : BroadcastedDeployAccountTxnV3.fromJson(json);
}
