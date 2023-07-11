// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compiled_contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SierraCompiledContract _$$_SierraCompiledContractFromJson(
        Map<String, dynamic> json) =>
    _$_SierraCompiledContract(
      sierraProgram: (json['sierra_program'] as List<dynamic>)
          .map((e) => BigInt.parse(e as String))
          .toList(),
      entryPointsByType: EntryPointsByType.fromJson(
          json['entry_points_by_type'] as Map<String, dynamic>),
      contractClassVersion: json['contract_class_version'] as String,
      abi: (json['abi'] as List<dynamic>)
          .map(
              (e) => SierraContractAbiEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_SierraCompiledContractToJson(
        _$_SierraCompiledContract instance) =>
    <String, dynamic>{
      'sierra_program':
          instance.sierraProgram.map((e) => e.toString()).toList(),
      'entry_points_by_type': instance.entryPointsByType.toJson(),
      'contract_class_version': instance.contractClassVersion,
      'abi': instance.abi.map((e) => e.toJson()).toList(),
    };

_$_DeprecatedCompiledContract _$$_DeprecatedCompiledContractFromJson(
        Map<String, dynamic> json) =>
    _$_DeprecatedCompiledContract(
      program: json['program'] as Map<String, dynamic>,
      entryPointsByType: DeprecatedCairoEntryPointsByType.fromJson(
          json['entry_points_by_type'] as Map<String, dynamic>),
      abi: (json['abi'] as List<dynamic>?)
          ?.map((e) => ContractAbiEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_DeprecatedCompiledContractToJson(
        _$_DeprecatedCompiledContract instance) =>
    <String, dynamic>{
      'program': instance.program,
      'entry_points_by_type': instance.entryPointsByType.toJson(),
      'abi': instance.abi?.map((e) => e.toJson()).toList(),
    };
