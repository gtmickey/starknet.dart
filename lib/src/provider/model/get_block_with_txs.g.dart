// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_block_with_txs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BlockWithTxs _$$BlockWithTxsFromJson(Map<String, dynamic> json) =>
    _$BlockWithTxs(
      result: BlockWithTxs.fromJson(json['result'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$BlockWithTxsToJson(_$BlockWithTxs instance) =>
    <String, dynamic>{
      'result': instance.result.toJson(),
      'runtimeType': instance.$type,
    };

_$PendingBlock _$$PendingBlockFromJson(Map<String, dynamic> json) =>
    _$PendingBlock(
      pendingBlock: PendingBlockWithTxs.fromJson(
          json['pending_block'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$PendingBlockToJson(_$PendingBlock instance) =>
    <String, dynamic>{
      'pending_block': instance.pendingBlock.toJson(),
      'runtimeType': instance.$type,
    };

_$GetBlockWithTxsError _$$GetBlockWithTxsErrorFromJson(
        Map<String, dynamic> json) =>
    _$GetBlockWithTxsError(
      error: JsonRpcApiError.fromJson(json['error'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$GetBlockWithTxsErrorToJson(
        _$GetBlockWithTxsError instance) =>
    <String, dynamic>{
      'error': instance.error.toJson(),
      'runtimeType': instance.$type,
    };
