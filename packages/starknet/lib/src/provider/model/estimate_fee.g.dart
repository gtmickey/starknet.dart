// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estimate_fee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EstimateFeeRequest _$EstimateFeeRequestFromJson(Map<String, dynamic> json) =>
    EstimateFeeRequest(
      request: (json['request'] as List<dynamic>)
          .map((e) => BroadcastedTxn.fromJson(e as Map<String, dynamic>))
          .toList(),
      blockId: BlockId.fromJson(json['block_id'] as Map<String, dynamic>),
      simulation_flags: (json['simulation_flags'] as List<dynamic>)
          .map((e) => SimulationFlag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EstimateFeeRequestToJson(EstimateFeeRequest instance) =>
    <String, dynamic>{
      'request': instance.request.map((e) => e.toJson()).toList(),
      'block_id': instance.blockId.toJson(),
      'simulation_flags':
          instance.simulation_flags.map((e) => e.toJson()).toList(),
    };

_$EstimateFeeResultImpl _$$EstimateFeeResultImplFromJson(
        Map<String, dynamic> json) =>
    _$EstimateFeeResultImpl(
      result: (json['result'] as List<dynamic>)
          .map((e) => FeeEstimate.fromJson(e as Map<String, dynamic>))
          .toList(),
      $type: json['starkNetRuntimeTypeToRemove'] as String?,
    );

Map<String, dynamic> _$$EstimateFeeResultImplToJson(
        _$EstimateFeeResultImpl instance) =>
    <String, dynamic>{
      'result': instance.result.map((e) => e.toJson()).toList(),
      'starkNetRuntimeTypeToRemove': instance.$type,
    };

_$EstimateFeeErrorImpl _$$EstimateFeeErrorImplFromJson(
        Map<String, dynamic> json) =>
    _$EstimateFeeErrorImpl(
      error: JsonRpcApiError.fromJson(json['error'] as Map<String, dynamic>),
      $type: json['starkNetRuntimeTypeToRemove'] as String?,
    );

Map<String, dynamic> _$$EstimateFeeErrorImplToJson(
        _$EstimateFeeErrorImpl instance) =>
    <String, dynamic>{
      'error': instance.error.toJson(),
      'starkNetRuntimeTypeToRemove': instance.$type,
    };

_$SkipValidateImpl _$$SkipValidateImplFromJson(Map<String, dynamic> json) =>
    _$SkipValidateImpl(
      $type: json['starkNetRuntimeTypeToRemove'] as String?,
    );

Map<String, dynamic> _$$SkipValidateImplToJson(_$SkipValidateImpl instance) =>
    <String, dynamic>{
      'starkNetRuntimeTypeToRemove': instance.$type,
    };

_$SkipFeeChargeImpl _$$SkipFeeChargeImplFromJson(Map<String, dynamic> json) =>
    _$SkipFeeChargeImpl(
      $type: json['starkNetRuntimeTypeToRemove'] as String?,
    );

Map<String, dynamic> _$$SkipFeeChargeImplToJson(_$SkipFeeChargeImpl instance) =>
    <String, dynamic>{
      'starkNetRuntimeTypeToRemove': instance.$type,
    };

_$BroadcastedInvokeTxnV0Impl _$$BroadcastedInvokeTxnV0ImplFromJson(
        Map<String, dynamic> json) =>
    _$BroadcastedInvokeTxnV0Impl(
      type: json['type'] as String,
      maxFee: Felt.fromJson(json['max_fee'] as String),
      version: json['version'] as String,
      signature: (json['signature'] as List<dynamic>)
          .map((e) => Felt.fromJson(e as String))
          .toList(),
      nonce:
          json['nonce'] == null ? null : Felt.fromJson(json['nonce'] as String),
      contractAddress: Felt.fromJson(json['contract_address'] as String),
      entryPointSelector: Felt.fromJson(json['entry_point_selector'] as String),
      calldata: (json['calldata'] as List<dynamic>)
          .map((e) => Felt.fromJson(e as String))
          .toList(),
      $type: json['starkNetRuntimeTypeToRemove'] as String?,
    );

Map<String, dynamic> _$$BroadcastedInvokeTxnV0ImplToJson(
    _$BroadcastedInvokeTxnV0Impl instance) {
  final val = <String, dynamic>{
    'type': instance.type,
    'max_fee': maxFeeToJson(instance.maxFee),
    'version': instance.version,
    'signature': instance.signature.map((e) => e.toJson()).toList(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('nonce', instance.nonce?.toJson());
  val['contract_address'] = instance.contractAddress.toJson();
  val['entry_point_selector'] = instance.entryPointSelector.toJson();
  val['calldata'] = instance.calldata.map((e) => e.toJson()).toList();
  val['starkNetRuntimeTypeToRemove'] = instance.$type;
  return val;
}

_$BroadcastedInvokeTxnV1Impl _$$BroadcastedInvokeTxnV1ImplFromJson(
        Map<String, dynamic> json) =>
    _$BroadcastedInvokeTxnV1Impl(
      type: json['type'] as String,
      maxFee: Felt.fromJson(json['max_fee'] as String),
      version: json['version'] as String,
      signature: (json['signature'] as List<dynamic>)
          .map((e) => Felt.fromJson(e as String))
          .toList(),
      nonce: Felt.fromJson(json['nonce'] as String),
      senderAddress: Felt.fromJson(json['sender_address'] as String),
      calldata: (json['calldata'] as List<dynamic>)
          .map((e) => Felt.fromJson(e as String))
          .toList(),
      $type: json['starkNetRuntimeTypeToRemove'] as String?,
    );

Map<String, dynamic> _$$BroadcastedInvokeTxnV1ImplToJson(
        _$BroadcastedInvokeTxnV1Impl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'max_fee': maxFeeToJson(instance.maxFee),
      'version': instance.version,
      'signature': instance.signature.map((e) => e.toJson()).toList(),
      'nonce': instance.nonce.toJson(),
      'sender_address': instance.senderAddress.toJson(),
      'calldata': instance.calldata.map((e) => e.toJson()).toList(),
      'starkNetRuntimeTypeToRemove': instance.$type,
    };

_$BroadcastedInvokeTxnV3Impl _$$BroadcastedInvokeTxnV3ImplFromJson(
        Map<String, dynamic> json) =>
    _$BroadcastedInvokeTxnV3Impl(
      accountDeploymentData: (json['account_deployment_data'] as List<dynamic>)
          .map((e) => Felt.fromJson(e as String))
          .toList(),
      calldata: (json['calldata'] as List<dynamic>)
          .map((e) => Felt.fromJson(e as String))
          .toList(),
      feeDataAvailabilityMode: json['fee_data_availability_mode'] as String,
      nonce: Felt.fromJson(json['nonce'] as String),
      nonceDataAvailabilityMode: json['nonce_data_availability_mode'] as String,
      paymasterData: (json['paymaster_data'] as List<dynamic>)
          .map((e) => Felt.fromJson(e as String))
          .toList(),
      resourceBounds: json['resource_bounds'] as Map<String, dynamic>,
      senderAddress: Felt.fromJson(json['sender_address'] as String),
      signature: (json['signature'] as List<dynamic>)
          .map((e) => Felt.fromJson(e as String))
          .toList(),
      tip: Felt.fromJson(json['tip'] as String),
      version: json['version'] as String,
      type: json['type'] as String,
      $type: json['starkNetRuntimeTypeToRemove'] as String?,
    );

Map<String, dynamic> _$$BroadcastedInvokeTxnV3ImplToJson(
        _$BroadcastedInvokeTxnV3Impl instance) =>
    <String, dynamic>{
      'account_deployment_data':
          instance.accountDeploymentData.map((e) => e.toJson()).toList(),
      'calldata': instance.calldata.map((e) => e.toJson()).toList(),
      'fee_data_availability_mode': instance.feeDataAvailabilityMode,
      'nonce': instance.nonce.toJson(),
      'nonce_data_availability_mode': instance.nonceDataAvailabilityMode,
      'paymaster_data': instance.paymasterData.map((e) => e.toJson()).toList(),
      'resource_bounds': instance.resourceBounds,
      'sender_address': instance.senderAddress.toJson(),
      'signature': instance.signature.map((e) => e.toJson()).toList(),
      'tip': instance.tip.toJson(),
      'version': instance.version,
      'type': instance.type,
      'starkNetRuntimeTypeToRemove': instance.$type,
    };

_$BroadcastedDeclareTxnImpl _$$BroadcastedDeclareTxnImplFromJson(
        Map<String, dynamic> json) =>
    _$BroadcastedDeclareTxnImpl(
      type: json['type'] as String,
      maxFee: Felt.fromJson(json['max_fee'] as String),
      version: json['version'] as String,
      signature: (json['signature'] as List<dynamic>)
          .map((e) => Felt.fromJson(e as String))
          .toList(),
      nonce: Felt.fromJson(json['nonce'] as String),
      contractClass: DeprecatedContractClass.fromJson(
          json['contract_class'] as Map<String, dynamic>),
      senderAddress: Felt.fromJson(json['sender_address'] as String),
      $type: json['starkNetRuntimeTypeToRemove'] as String?,
    );

Map<String, dynamic> _$$BroadcastedDeclareTxnImplToJson(
        _$BroadcastedDeclareTxnImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'max_fee': maxFeeToJson(instance.maxFee),
      'version': instance.version,
      'signature': instance.signature.map((e) => e.toJson()).toList(),
      'nonce': instance.nonce.toJson(),
      'contract_class': instance.contractClass.toJson(),
      'sender_address': instance.senderAddress.toJson(),
      'starkNetRuntimeTypeToRemove': instance.$type,
    };

_$BroadcastedDeployTxnImpl _$$BroadcastedDeployTxnImplFromJson(
        Map<String, dynamic> json) =>
    _$BroadcastedDeployTxnImpl(
      contractClass: DeprecatedContractClass.fromJson(
          json['contract_class'] as Map<String, dynamic>),
      version: json['version'] as String,
      type: json['type'] as String,
      contractAddressSalt:
          Felt.fromJson(json['contract_address_salt'] as String),
      constructorCalldata: (json['constructor_calldata'] as List<dynamic>)
          .map((e) => Felt.fromJson(e as String))
          .toList(),
      $type: json['starkNetRuntimeTypeToRemove'] as String?,
    );

Map<String, dynamic> _$$BroadcastedDeployTxnImplToJson(
        _$BroadcastedDeployTxnImpl instance) =>
    <String, dynamic>{
      'contract_class': instance.contractClass.toJson(),
      'version': instance.version,
      'type': instance.type,
      'contract_address_salt': instance.contractAddressSalt.toJson(),
      'constructor_calldata':
          instance.constructorCalldata.map((e) => e.toJson()).toList(),
      'starkNetRuntimeTypeToRemove': instance.$type,
    };

_$BroadcastedDeployAccountTxnImpl _$$BroadcastedDeployAccountTxnImplFromJson(
        Map<String, dynamic> json) =>
    _$BroadcastedDeployAccountTxnImpl(
      contractAddressSalt:
          Felt.fromJson(json['contract_address_salt'] as String),
      classHash: Felt.fromJson(json['class_hash'] as String),
      constructorCalldata: (json['constructor_calldata'] as List<dynamic>)
          .map((e) => Felt.fromJson(e as String))
          .toList(),
      type: json['type'] as String,
      maxFee: Felt.fromJson(json['max_fee'] as String),
      version: json['version'] as String,
      signature: (json['signature'] as List<dynamic>)
          .map((e) => Felt.fromJson(e as String))
          .toList(),
      nonce: Felt.fromJson(json['nonce'] as String),
      $type: json['starkNetRuntimeTypeToRemove'] as String?,
    );

Map<String, dynamic> _$$BroadcastedDeployAccountTxnImplToJson(
        _$BroadcastedDeployAccountTxnImpl instance) =>
    <String, dynamic>{
      'contract_address_salt': instance.contractAddressSalt.toJson(),
      'class_hash': instance.classHash.toJson(),
      'constructor_calldata':
          instance.constructorCalldata.map((e) => e.toJson()).toList(),
      'type': instance.type,
      'max_fee': maxFeeToJson(instance.maxFee),
      'version': instance.version,
      'signature': instance.signature.map((e) => e.toJson()).toList(),
      'nonce': instance.nonce.toJson(),
      'starkNetRuntimeTypeToRemove': instance.$type,
    };

_$BroadcastedDeployAccountTxnV3Impl
    _$$BroadcastedDeployAccountTxnV3ImplFromJson(Map<String, dynamic> json) =>
        _$BroadcastedDeployAccountTxnV3Impl(
          contractAddressSalt:
              Felt.fromJson(json['contract_address_salt'] as String),
          classHash: Felt.fromJson(json['class_hash'] as String),
          constructorCalldata: (json['constructor_calldata'] as List<dynamic>)
              .map((e) => Felt.fromJson(e as String))
              .toList(),
          feeDataAvailabilityMode: json['fee_data_availability_mode'] as String,
          nonceDataAvailabilityMode:
              json['nonce_data_availability_mode'] as String,
          paymasterData: (json['paymaster_data'] as List<dynamic>)
              .map((e) => Felt.fromJson(e as String))
              .toList(),
          resourceBounds: json['resource_bounds'] as Map<String, dynamic>,
          tip: Felt.fromJson(json['tip'] as String),
          type: json['type'] as String,
          version: json['version'] as String,
          signature: (json['signature'] as List<dynamic>)
              .map((e) => Felt.fromJson(e as String))
              .toList(),
          nonce: Felt.fromJson(json['nonce'] as String),
          $type: json['starkNetRuntimeTypeToRemove'] as String?,
        );

Map<String, dynamic> _$$BroadcastedDeployAccountTxnV3ImplToJson(
        _$BroadcastedDeployAccountTxnV3Impl instance) =>
    <String, dynamic>{
      'contract_address_salt': instance.contractAddressSalt.toJson(),
      'class_hash': instance.classHash.toJson(),
      'constructor_calldata':
          instance.constructorCalldata.map((e) => e.toJson()).toList(),
      'fee_data_availability_mode': instance.feeDataAvailabilityMode,
      'nonce_data_availability_mode': instance.nonceDataAvailabilityMode,
      'paymaster_data': instance.paymasterData.map((e) => e.toJson()).toList(),
      'resource_bounds': instance.resourceBounds,
      'tip': instance.tip.toJson(),
      'type': instance.type,
      'version': instance.version,
      'signature': instance.signature.map((e) => e.toJson()).toList(),
      'nonce': instance.nonce.toJson(),
      'starkNetRuntimeTypeToRemove': instance.$type,
    };
