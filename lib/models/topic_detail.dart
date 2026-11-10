import 'package:json_annotation/json_annotation.dart';

import '../net/http_config.dart';

part 'topic_detail.g.dart';

@JsonSerializable()
class TopicDetail {
  final int? id;
  final String? title;
  @JsonKey(name: 'fancy_title')
  final String? fancyTitle;
  @JsonKey(name: 'posts_count')
  final int? postsCount;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final int? views;
  @JsonKey(name: 'reply_count')
  final int? replyCount;
  @JsonKey(name: 'like_count')
  final int? likeCount;
  @JsonKey(name: 'last_posted_at')
  final String? lastPostedAt;
  final bool? visible;
  final bool? closed;
  final bool? archived;
  final String? archetype;
  final String? slug;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @JsonKey(name: 'word_count')
  final int? wordCount;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'current_post_number')
  final int? currentPostNumber;
  @JsonKey(name: 'highest_post_number')
  final int? highestPostNumber;
  @JsonKey(name: 'last_read_post_number')
  final int? lastReadPostNumber;
  @JsonKey(name: 'last_read_post_id')
  final int? lastReadPostId;
  @JsonKey(name: 'chunk_size')
  final int? chunkSize;
  @JsonKey(name: 'post_stream')
  final PostStream? postStream;
  final List<String>? tags;
  final String? categoryName;
  @JsonKey(name: 'details')
  final Detail? details;
  @JsonKey(name: 'participants_count')
  final int? participantsCount;
  @JsonKey(name: 'bookmarks')
  final List<Bookmarks>? bookmarks;
  final bool? bookmarked;

  TopicDetail({
    this.id,
    this.title,
    this.fancyTitle,
    this.postsCount,
    this.createdAt,
    this.views,
    this.replyCount,
    this.likeCount,
    this.lastPostedAt,
    this.visible,
    this.closed,
    this.archived,
    this.archetype,
    this.slug,
    this.categoryId,
    this.wordCount,
    this.userId,
    this.currentPostNumber,
    this.highestPostNumber,
    this.lastReadPostNumber,
    this.lastReadPostId,
    this.chunkSize,
    this.postStream,
    this.tags,
    this.categoryName,
    this.details,
    this.participantsCount,
    this.bookmarks,
    this.bookmarked,
  });

  factory TopicDetail.fromJson(Map<String, dynamic> json) =>
      _$TopicDetailFromJson(json);
  Map<String, dynamic> toJson() => _$TopicDetailToJson(this);
}

@JsonSerializable()
class PostStream {
  List<Post>? posts;
  List<int>? stream;

  PostStream({
    this.posts,
    this.stream,
  });

  factory PostStream.fromJson(Map<String, dynamic> json) =>
      _$PostStreamFromJson(json);
  Map<String, dynamic> toJson() => _$PostStreamToJson(this);
}

class PostRepliesResponse {
  final List<Post> replies;

  PostRepliesResponse({required this.replies});

  factory PostRepliesResponse.fromJson(List<dynamic> json) {
    return PostRepliesResponse(
      replies: json.map((e) => Post.fromJson(e)).toList(),
    );
  }
}

@JsonSerializable()
class Post {
  final int? id;
  final String? name;
  final String? username;
  final String? avatarTemplate;
  final String? createdAt;
  String? cooked;
  final int? postNumber;
  final int? postType;
  final int? postsCount;
  final String? updatedAt;
  final int? replyCount;
  final int? replyToPostNumber;
  final int? quoteCount;
  final int? incomingLinkCount;
  final int? reads;
  final int? readersCount;
  final double? score;
  final bool? yours;
  final int? topicId;
  final String? topicSlug;
  final String? displayUsername;
  final String? primaryGroupName;
  final String? flairName;
  final String? flairUrl;
  final String? flairBgColor;
  final String? flairColor;
  final int? flairGroupId;
  final List<dynamic>? badgesGranted;
  final int? version;
  final bool? canEdit;
  final bool? canDelete;
  final bool? canRecover;
  final bool? canSeeHiddenPost;
  final bool? canWiki;
  final String? userTitle;
  final bool? titleIsGroup;
  bool? bookmarked;
  final List<dynamic>? actionsSummary;
  final bool? moderator;
  final bool? admin;
  final bool? staff;
  final int? userId;
  final bool? hidden;
  final int? trustLevel;
  final String? deletedAt;
  final bool? userDeleted;
  final String? editReason;
  final bool? canViewEditHistory;
  final bool? wiki;
  final Map<String, dynamic>? userStatus;
  final List<dynamic>? mentionedUsers;
  final String? postUrl;
  final String? animatedAvatar;
  final String? userCakedate;
  final String? userBirthdate;
  final Map<String, dynamic>? event;
  final List<dynamic>? calendarDetails;
  final String? categoryExpertApprovedGroup;
  final bool? needsCategoryExpertApproval;
  final bool? canManageCategoryExpertPosts;
  final String? postFoldingStatus;
  final List<dynamic>? reactions;
  final Map<String, dynamic>? currentUserReaction;
  final int reactionUsersCount;
  final String? userSignature;
  final bool? canAcceptAnswer;
  final bool? canUnacceptAnswer;
  final bool? acceptedAnswer;
  final bool? topicAcceptedAnswer;
  final bool? canVote;
  final int? bookmarkAutoDeletePreference;
  final int? bookmarkId;
  final String? bookmarkableType;
  final String? bookmarkReminderAt;
  final String? bookmarkName;
  final bool? policyAccepted;
  final List<Polls>? polls;
  final PollsVotes? polls_votes;
  final String? actionCode;

  List<Post>? replayList;

  Post({
    this.id,
    this.name,
    this.username,
    this.avatarTemplate,
    this.createdAt,
    this.cooked,
    this.postNumber,
    this.postType,
    this.postsCount,
    this.updatedAt,
    this.replyCount,
    this.replyToPostNumber,
    this.quoteCount,
    this.incomingLinkCount,
    this.reads,
    this.readersCount,
    this.score,
    this.yours,
    this.topicId,
    this.topicSlug,
    this.displayUsername,
    this.primaryGroupName,
    this.flairName,
    this.flairUrl,
    this.flairBgColor,
    this.flairColor,
    this.flairGroupId,
    this.badgesGranted,
    this.version,
    this.canEdit,
    this.canDelete,
    this.canRecover,
    this.canSeeHiddenPost,
    this.canWiki,
    this.userTitle,
    this.titleIsGroup,
    this.bookmarked,
    this.actionsSummary,
    this.moderator,
    this.admin,
    this.staff,
    this.userId,
    this.hidden,
    this.trustLevel,
    this.deletedAt,
    this.userDeleted,
    this.editReason,
    this.canViewEditHistory,
    this.wiki,
    this.userStatus,
    this.mentionedUsers,
    this.postUrl,
    this.animatedAvatar,
    this.userCakedate,
    this.userBirthdate,
    this.event,
    this.calendarDetails,
    this.categoryExpertApprovedGroup,
    this.needsCategoryExpertApproval,
    this.canManageCategoryExpertPosts,
    this.postFoldingStatus,
    this.reactions,
    this.currentUserReaction,
    this.reactionUsersCount = 0,
    this.userSignature,
    this.canAcceptAnswer,
    this.canUnacceptAnswer,
    this.acceptedAnswer,
    this.topicAcceptedAnswer,
    this.canVote,
    this.bookmarkAutoDeletePreference,
    this.bookmarkId,
    this.bookmarkableType,
    this.bookmarkReminderAt,
    this.bookmarkName,
    this.policyAccepted,
    this.polls,
    this.polls_votes,
    this.actionCode,
  });

  String get avatarUrl {
    if (animatedAvatar != null && animatedAvatar!.isNotEmpty) {
      if (animatedAvatar!.startsWith('http://') ||
          animatedAvatar!.startsWith('https://')) {
        return animatedAvatar!;
      }
      return '${HttpConfig.baseUrl}${animatedAvatar!.replaceAll('{size}', '62')}';
    }
    if (avatarTemplate == null || avatarTemplate!.isEmpty) {
      return '';
    }
    if (avatarTemplate!.startsWith('http://') ||
        avatarTemplate!.startsWith('https://')) {
      return avatarTemplate!;
    }
    return '${HttpConfig.baseUrl}${avatarTemplate!.replaceAll('{size}', '62')}';
  }

  bool isWebMaster() {
    return userId == 1;
  }

  bool isForumMaster(int id) {
    return id == userId;
  }

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int?,
        name: json['name'] as String?,
        username: json['username'] as String?,
        avatarTemplate: json['avatar_template'] as String?,
        createdAt: json['created_at'] as String?,
        cooked: json['cooked'] as String?,
        postNumber: json['post_number'] as int?,
        postType: json['post_type'] as int?,
        postsCount: json['posts_count'] as int?,
        updatedAt: json['updated_at'] as String?,
        replyCount: json['reply_count'] as int?,
        replyToPostNumber: json['reply_to_post_number'] as int?,
        quoteCount: json['quote_count'] as int?,
        incomingLinkCount: json['incoming_link_count'] as int?,
        reads: json['reads'] as int?,
        readersCount: json['readers_count'] as int?,
        score: (json['score'] as num?)?.toDouble(),
        yours: json['yours'] as bool?,
        topicId: json['topic_id'] as int?,
        topicSlug: json['topic_slug'] as String?,
        displayUsername: json['display_username'] as String?,
        primaryGroupName: json['primary_group_name'] as String?,
        flairName: json['flair_name'] as String?,
        flairUrl: json['flair_url'] as String?,
        flairBgColor: json['flair_bg_color'] as String?,
        flairColor: json['flair_color'] as String?,
        flairGroupId: json['flair_group_id'] as int?,
        badgesGranted: json['badges_granted'] as List<dynamic>?,
        version: json['version'] as int?,
        canEdit: json['can_edit'] as bool?,
        canDelete: json['can_delete'] as bool?,
        canRecover: json['can_recover'] as bool?,
        canSeeHiddenPost: json['can_see_hidden_post'] as bool?,
        canWiki: json['can_wiki'] as bool?,
        userTitle: json['user_title'] as String?,
        titleIsGroup: json['title_is_group'] as bool?,
        bookmarked: json['bookmarked'] as bool?,
        actionsSummary: json['actions_summary'] as List<dynamic>?,
        moderator: json['moderator'] as bool?,
        admin: json['admin'] as bool?,
        staff: json['staff'] as bool?,
        userId: json['user_id'] as int?,
        hidden: json['hidden'] as bool?,
        trustLevel: json['trust_level'] as int?,
        deletedAt: json['deleted_at'] as String?,
        userDeleted: json['user_deleted'] as bool?,
        editReason: json['edit_reason'] as String?,
        canViewEditHistory: json['can_view_edit_history'] as bool?,
        wiki: json['wiki'] as bool?,
        userStatus: json['user_status'] as Map<String, dynamic>?,
        mentionedUsers: json['mentioned_users'] as List<dynamic>?,
        postUrl: json['post_url'] as String?,
        animatedAvatar: json['animated_avatar'] as String?,
        userCakedate: json['user_cakedate'] as String?,
        userBirthdate: json['user_birthdate'] as String?,
        event: json['event'] as Map<String, dynamic>?,
        calendarDetails: json['calendar_details'] as List<dynamic>?,
        categoryExpertApprovedGroup:
            json['category_expert_approved_group'] as String?,
        needsCategoryExpertApproval:
            json['needs_category_expert_approval'] as bool?,
        canManageCategoryExpertPosts:
            json['can_manage_category_expert_posts'] as bool?,
        postFoldingStatus: json['post_folding_status'] as String?,
        reactions: json['reactions'] as List<dynamic>?,
        currentUserReaction:
            json['current_user_reaction'] as Map<String, dynamic>?,
        reactionUsersCount:
            (json['reaction_users_count'] as num?)?.toInt() ?? 0,
        userSignature: json['user_signature'] as String?,
        canAcceptAnswer: json['can_accept_answer'] as bool?,
        canUnacceptAnswer: json['can_unaccept_answer'] as bool?,
        acceptedAnswer: json['accepted_answer'] as bool?,
        topicAcceptedAnswer: json['topic_accepted_answer'] as bool?,
        canVote: json['can_vote'] as bool?,
        bookmarkAutoDeletePreference:
            json['bookmark_auto_delete_preference'] as int?,
        bookmarkId: json['bookmark_id'] as int?,
        bookmarkableType: json['bookmarkable_type'] as String?,
        bookmarkReminderAt: json['bookmark_reminder_at'] as String?,
        bookmarkName: json['bookmark_name'] as String?,
        policyAccepted: json['policy_accepted'] as bool?,
        polls: json['polls'] != null
            ? (json['polls'] as List<dynamic>)
                .map((e) => Polls.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        polls_votes: json['polls_votes'] != null
            ? PollsVotes.fromJson(json['polls_votes'] as Map<String, dynamic>)
            : null,
        actionCode: json['action_code'] as String?,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'user_id': userId,
      'avatar_template': avatarTemplate,
      'created_at': createdAt,
      'cooked': cooked,
      'post_number': postNumber,
      'post_type': postType,
      'updated_at': updatedAt,
      'reply_count': replyCount,
      'quote_count': quoteCount,
      'incoming_link_count': incomingLinkCount,
      'reads': reads,
      'score': score,
      'yours': yours,
      'topic_id': topicId,
      'topic_slug': topicSlug,
      'display_username': displayUsername,
      'primary_group_name': primaryGroupName,
      'hidden': hidden,
      'trust_level': trustLevel,
      'user_title': userTitle,
      'bookmarked': bookmarked,
      'actions_summary': actionsSummary?.map((x) => x.toJson()).toList(),
      'reply_to_post_number': replyToPostNumber,
      'reaction_users_count': reactionUsersCount,
      'posts_count': postsCount,
      'readers_count': readersCount,
      'moderator': moderator,
      'bookmark_auto_delete_preference': bookmarkAutoDeletePreference,
      'bookmark_id': bookmarkId,
      'bookmarkable_type': bookmarkableType,
      'bookmark_reminder_at': bookmarkReminderAt,
      'policy_accepted': policyAccepted,
      'polls': polls?.map((e) => e.toJson()).toList(),
      'polls_votes': polls_votes?.toJson(),
      'action_code': actionCode,
    };
  }
}

@JsonSerializable()
class ActionSummary {
  final int id;
  final int? count;
  final bool? hidden;
  @JsonKey(name: 'can_act')
  final bool? canAct;

  ActionSummary({
    required this.id,
    this.count,
    this.hidden,
    this.canAct,
  });

  factory ActionSummary.fromJson(Map<String, dynamic> json) =>
      _$ActionSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$ActionSummaryToJson(this);
}

@JsonSerializable()
class Detail {
  @JsonKey(name: 'created_by')
  final CreateBy? createdBy;
  final List<Links>? links;

  Detail({
    this.createdBy,
    this.links,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => _$DetailFromJson(json);
  Map<String, dynamic> toJson() => _$DetailToJson(this);
}

@JsonSerializable()
class Links {
  final bool? attachment;
  final int? clicks;
  final String? domain;
  final bool? internal;
  final bool? reflection;
  @JsonKey(name: 'root_domain')
  final String? rootDomain;
  final String? title;
  final String? url;
  @JsonKey(name: 'user_id')
  final int? userId;

  Links({
    this.attachment,
    this.clicks,
    this.domain,
    this.internal,
    this.reflection,
    this.rootDomain,
    this.title,
    this.url,
    this.userId,
  });

  factory Links.fromJson(Map<String, dynamic> json) => _$LinksFromJson(json);
  Map<String, dynamic> toJson() => _$LinksToJson(this);
}

@JsonSerializable()
class CreateBy {
  final int? id;
  final String? name;
  final String? username;
  @JsonKey(name: 'avatar_template')
  final String? avatarTemplate;
  @JsonKey(name: 'animated_avatar')
  final String? animatedAvatar;

  CreateBy({
    this.id,
    this.name,
    this.username,
    this.avatarTemplate,
    this.animatedAvatar,
  });

  String getAvatarUrl() {
    return '${HttpConfig.baseUrl}${avatarTemplate!.replaceAll("{size}", "62")}';
  }

  bool isWebMaster() {
    return id == 1;
  }

  factory CreateBy.fromJson(Map<String, dynamic> json) =>
      _$CreateByFromJson(json);
  Map<String, dynamic> toJson() => _$CreateByToJson(this);
}

@JsonSerializable()
class Bookmarks {
  @JsonKey(name: 'auto_delete_preference')
  final int? autoDeletePreference;
  @JsonKey(name: 'bookmarkable_id')
  final int? bookmarkableId;
  @JsonKey(name: 'bookmarkable_type')
  final String? bookmarkableType;
  final int? id;
  final String? name;
  @JsonKey(name: 'reminder_at')
  final String? reminderAt;

  Bookmarks(
    this.id,
    this.name,
    this.reminderAt,
    this.autoDeletePreference,
    this.bookmarkableId,
    this.bookmarkableType,
  );

  factory Bookmarks.fromJson(Map<String, dynamic> json) =>
      _$BookmarksFromJson(json);
  Map<String, dynamic> toJson() => _$BookmarksToJson(this);
}

@JsonSerializable()
class PollsVotes {
  final Map<String, List<String>> votes;

  PollsVotes({required this.votes});

  factory PollsVotes.fromJson(Map<String, dynamic> json) {
    final Map<String, List<String>> votesMap = {};

    json.forEach((key, value) {
      if (value is List) {
        votesMap[key] = value.cast<String>();
      }
    });

    return PollsVotes(votes: votesMap);
  }

  Map<String, dynamic> toJson() {
    return votes;
  }

  // 兼容旧代码的getter
  List<String>? get poll => votes['poll'];
}

@JsonSerializable()
class Polls {
  final int? id;
  final String? name;
  final String? type;
  final String? status;
  final bool? public;
  final String? results;
  final List<PollOption>? options;
  final int? voters;
  final Map<String, List<PollVoter>>? preloaded_voters;
  final String? chart_type;
  final String? title;
  List<String>? vote;
  int? postId;

  Polls({
    this.id,
    this.name,
    this.type,
    this.status,
    this.public,
    this.results,
    this.options,
    this.voters,
    this.preloaded_voters,
    this.chart_type,
    this.title,
    this.vote,
    this.postId,
  });

  factory Polls.fromJson(Map<String, dynamic> json) {
    return Polls(
      id: json['id'] as int?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      status: json['status'] as String?,
      public: json['public'] as bool?,
      results: json['results'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => PollOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      voters: json['voters'] as int?,
      preloaded_voters:
          (json['preloaded_voters'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((v) => PollVoter.fromJson(v as Map<String, dynamic>))
              .toList(),
        ),
      ),
      chart_type: json['chart_type'] as String?,
      title: json['title'] as String?,
      vote: json['vote'] as List<String>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'public': public,
      'results': results,
      'options': options?.map((e) => e.toJson()).toList(),
      'voters': voters,
      'preloaded_voters': preloaded_voters?.map(
        (k, e) => MapEntry(k, e.map((v) => v.toJson()).toList()),
      ),
      'chart_type': chart_type,
      'title': title,
      'vote': vote,
    };
  }
}

@JsonSerializable()
class PollOption {
  final String? id;
  final String? html;
  final int? votes;

  PollOption({
    this.id,
    this.html,
    this.votes,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'] as String?,
      html: json['html'] as String?,
      votes: json['votes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'html': html,
      'votes': votes,
    };
  }
}

@JsonSerializable()
class PollVoter {
  final int? id;
  final String? username;
  final String? name;
  final String? avatar_template;
  final String? title;
  final String? animated_avatar;

  PollVoter({
    this.id,
    this.username,
    this.name,
    this.avatar_template,
    this.title,
    this.animated_avatar,
  });

  factory PollVoter.fromJson(Map<String, dynamic> json) {
    return PollVoter(
      id: json['id'] as int?,
      username: json['username'] as String?,
      name: json['name'] as String?,
      avatar_template: json['avatar_template'] as String?,
      title: json['title'] as String?,
      animated_avatar: json['animated_avatar'] as String?,
    );
  }

  String getAvatarUrl() {
    if (animated_avatar != null && animated_avatar!.isNotEmpty) {
      if (animated_avatar!.startsWith('http://') ||
          animated_avatar!.startsWith('https://')) {
        return animated_avatar!;
      }
      return '${HttpConfig.baseUrl}${animated_avatar!.replaceAll('{size}', '40')}';
    }
    if (avatar_template == null || avatar_template!.isEmpty) {
      return '';
    }
    if (avatar_template!.startsWith('http://') ||
        avatar_template!.startsWith('https://')) {
      return avatar_template!;
    }
    return '${HttpConfig.baseUrl}${avatar_template!.replaceAll('{size}', '40')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'avatar_template': avatar_template,
      'title': title,
      'animated_avatar': animated_avatar,
    };
  }
}
