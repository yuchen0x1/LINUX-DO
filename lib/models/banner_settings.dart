import 'package:json_annotation/json_annotation.dart';

part 'banner_settings.g.dart';

@JsonSerializable()
class BannerSettings {
  final String? networkUrl; // 网络图片URL
  final String? localPath; // 本地图片路径
  final bool useDefault; // 是否使用默认图片

  BannerSettings({
    this.networkUrl,
    this.localPath,
    this.useDefault = true,
  });

  factory BannerSettings.fromJson(Map<String, dynamic> json) =>
      _$BannerSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$BannerSettingsToJson(this);

  String? get currentImageSource {
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return networkUrl;
    }
    if (localPath != null && localPath!.isNotEmpty) {
      return localPath;
    }
    return null;
  }

  // 是否使用网络图片
  bool get isNetworkImage => networkUrl != null && networkUrl!.isNotEmpty;

  // 是否使用本地图片
  bool get isLocalImage => localPath != null && localPath!.isNotEmpty;
}
