class ApiResponse<T> {
  int? code;
  String? message;
  T? data;

  ApiResponse({this.code, this.message, this.data});

  ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    code = json['code'] ?? 200; // 默认成功状态码为 200
    message = json['message'] ?? 'success';
    if (json['data'] != null && fromJson != null) {
      data = fromJson(json['data']);
    } else {
      data = json['data'] as T?;
    }
  }

  bool get isSuccess => code == 200;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    data['data'] = this.data;
    return data;
  }
}
