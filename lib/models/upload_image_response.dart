import 'package:json_annotation/json_annotation.dart';

part 'upload_image_response.g.dart';

@JsonSerializable()
class UploadImageResponse {
  final int id;
  final String url;
  @JsonKey(name: 'original_filename')
  final String originalFilename;
  final int filesize;
  final int width;
  final int height;
  @JsonKey(name: 'thumbnail_width')
  final int thumbnailWidth;
  @JsonKey(name: 'thumbnail_height')
  final int thumbnailHeight;
  final String extension;
  @JsonKey(name: 'short_url')
  final String shortUrl;
  @JsonKey(name: 'short_path')
  final String shortPath;
  @JsonKey(name: 'retain_hours')
  final int? retainHours;
  @JsonKey(name: 'human_filesize')
  final String humanFilesize;
  @JsonKey(name: 'dominant_color')
  final String dominantColor;
  final String? thumbnail;

  UploadImageResponse({
    required this.id,
    required this.url,
    required this.originalFilename,
    required this.filesize,
    required this.width,
    required this.height,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    required this.extension,
    required this.shortUrl,
    required this.shortPath,
    this.retainHours,
    required this.humanFilesize,
    required this.dominantColor,
    this.thumbnail,
  });

  factory UploadImageResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadImageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadImageResponseToJson(this);
}
