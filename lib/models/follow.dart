import 'package:json_annotation/json_annotation.dart';
import 'package:linux_do/net/http_config.dart';

part 'follow.g.dart';

class FollowResponse {
  final List<Follow> items;

  FollowResponse(this.items);

  factory FollowResponse.fromJson(List<dynamic> jsonArray) {
    final items = jsonArray
        .map((json) => Follow.fromJson(json as Map<String, dynamic>))
        .toList();
    return FollowResponse(items);
  }

  List<Follow> get follows => items;

  operator [](int index) => items[index];
  int get length => items.length;
}

@JsonSerializable()
class Follow {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'username')
  final String? username;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'avatar_template')
  final String? avatarTemplate;

  @JsonKey(name: 'animated_avatar')
  final String? animatedAvatar;

  Follow({
    this.id,
    this.username,
    this.name,
    this.avatarTemplate,
    this.animatedAvatar,
  });

  String get avatarUrl {
    if (animatedAvatar != null && animatedAvatar!.isNotEmpty) {
      if (animatedAvatar!.startsWith('http://') ||
          animatedAvatar!.startsWith('https://')) {
        return animatedAvatar!;
      }
      return '${HttpConfig.baseUrl}${animatedAvatar!.replaceAll('{size}', '80')}';
    }

    if (avatarTemplate == null || avatarTemplate!.isEmpty) {
      return '';
    }
    if (avatarTemplate!.startsWith('http://') ||
        avatarTemplate!.startsWith('https://')) {
      return avatarTemplate!;
    }
    return '${HttpConfig.baseUrl}${avatarTemplate!.replaceAll('{size}', '80')}';
  }

  bool get isWebMaster => id == 1;

  bool hasAnimatedAvatar() {
    return animatedAvatar != null && animatedAvatar!.isNotEmpty;
  }

  factory Follow.fromJson(Map<String, dynamic> json) => _$FollowFromJson(json);
  Map<String, dynamic> toJson() => _$FollowToJson(this);
}
