// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_image_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadImageResponse _$UploadImageResponseFromJson(Map<String, dynamic> json) =>
    UploadImageResponse(
      id: (json['id'] as num).toInt(),
      url: json['url'] as String,
      originalFilename: json['original_filename'] as String,
      filesize: (json['filesize'] as num).toInt(),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      thumbnailWidth: (json['thumbnail_width'] as num).toInt(),
      thumbnailHeight: (json['thumbnail_height'] as num).toInt(),
      extension: json['extension'] as String,
      shortUrl: json['short_url'] as String,
      shortPath: json['short_path'] as String,
      retainHours: (json['retain_hours'] as num?)?.toInt(),
      humanFilesize: json['human_filesize'] as String,
      dominantColor: json['dominant_color'] as String,
      thumbnail: json['thumbnail'] as String?,
    );

Map<String, dynamic> _$UploadImageResponseToJson(
  UploadImageResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'original_filename': instance.originalFilename,
  'filesize': instance.filesize,
  'width': instance.width,
  'height': instance.height,
  'thumbnail_width': instance.thumbnailWidth,
  'thumbnail_height': instance.thumbnailHeight,
  'extension': instance.extension,
  'short_url': instance.shortUrl,
  'short_path': instance.shortPath,
  'retain_hours': instance.retainHours,
  'human_filesize': instance.humanFilesize,
  'dominant_color': instance.dominantColor,
  'thumbnail': instance.thumbnail,
};
