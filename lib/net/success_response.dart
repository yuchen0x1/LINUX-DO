import 'package:json_annotation/json_annotation.dart';

part 'success_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class SuccessResponse<T> {
  final String? success;
  final T? data;

  SuccessResponse({this.success, this.data});

  bool get isSuccess => success == 'OK';

  factory SuccessResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return _$SuccessResponseFromJson(json, fromJsonT);
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$SuccessResponseToJson(this, toJsonT);
}
