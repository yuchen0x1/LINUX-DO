// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopicDetail _$TopicDetailFromJson(Map<String, dynamic> json) => TopicDetail(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  fancyTitle: json['fancy_title'] as String?,
  postsCount: (json['posts_count'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  views: (json['views'] as num?)?.toInt(),
  replyCount: (json['reply_count'] as num?)?.toInt(),
  likeCount: (json['like_count'] as num?)?.toInt(),
  lastPostedAt: json['last_posted_at'] as String?,
  visible: json['visible'] as bool?,
  closed: json['closed'] as bool?,
  archived: json['archived'] as bool?,
  archetype: json['archetype'] as String?,
  slug: json['slug'] as String?,
  categoryId: (json['category_id'] as num?)?.toInt(),
  wordCount: (json['word_count'] as num?)?.toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  currentPostNumber: (json['current_post_number'] as num?)?.toInt(),
  highestPostNumber: (json['highest_post_number'] as num?)?.toInt(),
  lastReadPostNumber: (json['last_read_post_number'] as num?)?.toInt(),
  lastReadPostId: (json['last_read_post_id'] as num?)?.toInt(),
  chunkSize: (json['chunk_size'] as num?)?.toInt(),
  postStream: json['post_stream'] == null
      ? null
      : PostStream.fromJson(json['post_stream'] as Map<String, dynamic>),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  categoryName: json['categoryName'] as String?,
  details: json['details'] == null
      ? null
      : Detail.fromJson(json['details'] as Map<String, dynamic>),
  participantsCount: (json['participants_count'] as num?)?.toInt(),
  bookmarks: (json['bookmarks'] as List<dynamic>?)
      ?.map((e) => Bookmarks.fromJson(e as Map<String, dynamic>))
      .toList(),
  bookmarked: json['bookmarked'] as bool?,
);

Map<String, dynamic> _$TopicDetailToJson(TopicDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'fancy_title': instance.fancyTitle,
      'posts_count': instance.postsCount,
      'created_at': instance.createdAt,
      'views': instance.views,
      'reply_count': instance.replyCount,
      'like_count': instance.likeCount,
      'last_posted_at': instance.lastPostedAt,
      'visible': instance.visible,
      'closed': instance.closed,
      'archived': instance.archived,
      'archetype': instance.archetype,
      'slug': instance.slug,
      'category_id': instance.categoryId,
      'word_count': instance.wordCount,
      'user_id': instance.userId,
      'current_post_number': instance.currentPostNumber,
      'highest_post_number': instance.highestPostNumber,
      'last_read_post_number': instance.lastReadPostNumber,
      'last_read_post_id': instance.lastReadPostId,
      'chunk_size': instance.chunkSize,
      'post_stream': instance.postStream,
      'tags': instance.tags,
      'categoryName': instance.categoryName,
      'details': instance.details,
      'participants_count': instance.participantsCount,
      'bookmarks': instance.bookmarks,
      'bookmarked': instance.bookmarked,
    };

PostStream _$PostStreamFromJson(Map<String, dynamic> json) => PostStream(
  posts: (json['posts'] as List<dynamic>?)
      ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
      .toList(),
  stream: (json['stream'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$PostStreamToJson(PostStream instance) =>
    <String, dynamic>{'posts': instance.posts, 'stream': instance.stream};

Post _$PostFromJson(Map<String, dynamic> json) =>
    Post(
        id: (json['id'] as num?)?.toInt(),
        name: json['name'] as String?,
        username: json['username'] as String?,
        avatarTemplate: json['avatarTemplate'] as String?,
        createdAt: json['createdAt'] as String?,
        cooked: json['cooked'] as String?,
        postNumber: (json['postNumber'] as num?)?.toInt(),
        postType: (json['postType'] as num?)?.toInt(),
        postsCount: (json['postsCount'] as num?)?.toInt(),
        updatedAt: json['updatedAt'] as String?,
        replyCount: (json['replyCount'] as num?)?.toInt(),
        replyToPostNumber: (json['replyToPostNumber'] as num?)?.toInt(),
        quoteCount: (json['quoteCount'] as num?)?.toInt(),
        incomingLinkCount: (json['incomingLinkCount'] as num?)?.toInt(),
        reads: (json['reads'] as num?)?.toInt(),
        readersCount: (json['readersCount'] as num?)?.toInt(),
        score: (json['score'] as num?)?.toDouble(),
        yours: json['yours'] as bool?,
        topicId: (json['topicId'] as num?)?.toInt(),
        topicSlug: json['topicSlug'] as String?,
        displayUsername: json['displayUsername'] as String?,
        primaryGroupName: json['primaryGroupName'] as String?,
        flairName: json['flairName'] as String?,
        flairUrl: json['flairUrl'] as String?,
        flairBgColor: json['flairBgColor'] as String?,
        flairColor: json['flairColor'] as String?,
        flairGroupId: (json['flairGroupId'] as num?)?.toInt(),
        badgesGranted: json['badgesGranted'] as List<dynamic>?,
        version: (json['version'] as num?)?.toInt(),
        canEdit: json['canEdit'] as bool?,
        canDelete: json['canDelete'] as bool?,
        canRecover: json['canRecover'] as bool?,
        canSeeHiddenPost: json['canSeeHiddenPost'] as bool?,
        canWiki: json['canWiki'] as bool?,
        userTitle: json['userTitle'] as String?,
        titleIsGroup: json['titleIsGroup'] as bool?,
        bookmarked: json['bookmarked'] as bool?,
        actionsSummary: json['actionsSummary'] as List<dynamic>?,
        moderator: json['moderator'] as bool?,
        admin: json['admin'] as bool?,
        staff: json['staff'] as bool?,
        userId: (json['userId'] as num?)?.toInt(),
        hidden: json['hidden'] as bool?,
        trustLevel: (json['trustLevel'] as num?)?.toInt(),
        deletedAt: json['deletedAt'] as String?,
        userDeleted: json['userDeleted'] as bool?,
        editReason: json['editReason'] as String?,
        canViewEditHistory: json['canViewEditHistory'] as bool?,
        wiki: json['wiki'] as bool?,
        userStatus: json['userStatus'] as Map<String, dynamic>?,
        mentionedUsers: json['mentionedUsers'] as List<dynamic>?,
        postUrl: json['postUrl'] as String?,
        animatedAvatar: json['animatedAvatar'] as String?,
        userCakedate: json['userCakedate'] as String?,
        userBirthdate: json['userBirthdate'] as String?,
        event: json['event'] as Map<String, dynamic>?,
        calendarDetails: json['calendarDetails'] as List<dynamic>?,
        categoryExpertApprovedGroup:
            json['categoryExpertApprovedGroup'] as String?,
        needsCategoryExpertApproval:
            json['needsCategoryExpertApproval'] as bool?,
        canManageCategoryExpertPosts:
            json['canManageCategoryExpertPosts'] as bool?,
        postFoldingStatus: json['postFoldingStatus'] as String?,
        reactions: json['reactions'] as List<dynamic>?,
        currentUserReaction:
            json['currentUserReaction'] as Map<String, dynamic>?,
        reactionUsersCount: (json['reactionUsersCount'] as num?)?.toInt() ?? 0,
        userSignature: json['userSignature'] as String?,
        canAcceptAnswer: json['canAcceptAnswer'] as bool?,
        canUnacceptAnswer: json['canUnacceptAnswer'] as bool?,
        acceptedAnswer: json['acceptedAnswer'] as bool?,
        topicAcceptedAnswer: json['topicAcceptedAnswer'] as bool?,
        canVote: json['canVote'] as bool?,
        bookmarkAutoDeletePreference:
            (json['bookmarkAutoDeletePreference'] as num?)?.toInt(),
        bookmarkId: (json['bookmarkId'] as num?)?.toInt(),
        bookmarkableType: json['bookmarkableType'] as String?,
        bookmarkReminderAt: json['bookmarkReminderAt'] as String?,
        bookmarkName: json['bookmarkName'] as String?,
        policyAccepted: json['policyAccepted'] as bool?,
        polls: (json['polls'] as List<dynamic>?)
            ?.map((e) => Polls.fromJson(e as Map<String, dynamic>))
            .toList(),
        polls_votes: json['polls_votes'] == null
            ? null
            : PollsVotes.fromJson(json['polls_votes'] as Map<String, dynamic>),
        actionCode: json['actionCode'] as String?,
      )
      ..replayList = (json['replayList'] as List<dynamic>?)
          ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
  'avatarTemplate': instance.avatarTemplate,
  'createdAt': instance.createdAt,
  'cooked': instance.cooked,
  'postNumber': instance.postNumber,
  'postType': instance.postType,
  'postsCount': instance.postsCount,
  'updatedAt': instance.updatedAt,
  'replyCount': instance.replyCount,
  'replyToPostNumber': instance.replyToPostNumber,
  'quoteCount': instance.quoteCount,
  'incomingLinkCount': instance.incomingLinkCount,
  'reads': instance.reads,
  'readersCount': instance.readersCount,
  'score': instance.score,
  'yours': instance.yours,
  'topicId': instance.topicId,
  'topicSlug': instance.topicSlug,
  'displayUsername': instance.displayUsername,
  'primaryGroupName': instance.primaryGroupName,
  'flairName': instance.flairName,
  'flairUrl': instance.flairUrl,
  'flairBgColor': instance.flairBgColor,
  'flairColor': instance.flairColor,
  'flairGroupId': instance.flairGroupId,
  'badgesGranted': instance.badgesGranted,
  'version': instance.version,
  'canEdit': instance.canEdit,
  'canDelete': instance.canDelete,
  'canRecover': instance.canRecover,
  'canSeeHiddenPost': instance.canSeeHiddenPost,
  'canWiki': instance.canWiki,
  'userTitle': instance.userTitle,
  'titleIsGroup': instance.titleIsGroup,
  'bookmarked': instance.bookmarked,
  'actionsSummary': instance.actionsSummary,
  'moderator': instance.moderator,
  'admin': instance.admin,
  'staff': instance.staff,
  'userId': instance.userId,
  'hidden': instance.hidden,
  'trustLevel': instance.trustLevel,
  'deletedAt': instance.deletedAt,
  'userDeleted': instance.userDeleted,
  'editReason': instance.editReason,
  'canViewEditHistory': instance.canViewEditHistory,
  'wiki': instance.wiki,
  'userStatus': instance.userStatus,
  'mentionedUsers': instance.mentionedUsers,
  'postUrl': instance.postUrl,
  'animatedAvatar': instance.animatedAvatar,
  'userCakedate': instance.userCakedate,
  'userBirthdate': instance.userBirthdate,
  'event': instance.event,
  'calendarDetails': instance.calendarDetails,
  'categoryExpertApprovedGroup': instance.categoryExpertApprovedGroup,
  'needsCategoryExpertApproval': instance.needsCategoryExpertApproval,
  'canManageCategoryExpertPosts': instance.canManageCategoryExpertPosts,
  'postFoldingStatus': instance.postFoldingStatus,
  'reactions': instance.reactions,
  'currentUserReaction': instance.currentUserReaction,
  'reactionUsersCount': instance.reactionUsersCount,
  'userSignature': instance.userSignature,
  'canAcceptAnswer': instance.canAcceptAnswer,
  'canUnacceptAnswer': instance.canUnacceptAnswer,
  'acceptedAnswer': instance.acceptedAnswer,
  'topicAcceptedAnswer': instance.topicAcceptedAnswer,
  'canVote': instance.canVote,
  'bookmarkAutoDeletePreference': instance.bookmarkAutoDeletePreference,
  'bookmarkId': instance.bookmarkId,
  'bookmarkableType': instance.bookmarkableType,
  'bookmarkReminderAt': instance.bookmarkReminderAt,
  'bookmarkName': instance.bookmarkName,
  'policyAccepted': instance.policyAccepted,
  'polls': instance.polls,
  'polls_votes': instance.polls_votes,
  'actionCode': instance.actionCode,
  'replayList': instance.replayList,
};

ActionSummary _$ActionSummaryFromJson(Map<String, dynamic> json) =>
    ActionSummary(
      id: (json['id'] as num).toInt(),
      count: (json['count'] as num?)?.toInt(),
      hidden: json['hidden'] as bool?,
      canAct: json['can_act'] as bool?,
    );

Map<String, dynamic> _$ActionSummaryToJson(ActionSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'count': instance.count,
      'hidden': instance.hidden,
      'can_act': instance.canAct,
    };

Detail _$DetailFromJson(Map<String, dynamic> json) => Detail(
  createdBy: json['created_by'] == null
      ? null
      : CreateBy.fromJson(json['created_by'] as Map<String, dynamic>),
  links: (json['links'] as List<dynamic>?)
      ?.map((e) => Links.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DetailToJson(Detail instance) => <String, dynamic>{
  'created_by': instance.createdBy,
  'links': instance.links,
};

Links _$LinksFromJson(Map<String, dynamic> json) => Links(
  attachment: json['attachment'] as bool?,
  clicks: (json['clicks'] as num?)?.toInt(),
  domain: json['domain'] as String?,
  internal: json['internal'] as bool?,
  reflection: json['reflection'] as bool?,
  rootDomain: json['root_domain'] as String?,
  title: json['title'] as String?,
  url: json['url'] as String?,
  userId: (json['user_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$LinksToJson(Links instance) => <String, dynamic>{
  'attachment': instance.attachment,
  'clicks': instance.clicks,
  'domain': instance.domain,
  'internal': instance.internal,
  'reflection': instance.reflection,
  'root_domain': instance.rootDomain,
  'title': instance.title,
  'url': instance.url,
  'user_id': instance.userId,
};

CreateBy _$CreateByFromJson(Map<String, dynamic> json) => CreateBy(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  username: json['username'] as String?,
  avatarTemplate: json['avatar_template'] as String?,
  animatedAvatar: json['animated_avatar'] as String?,
);

Map<String, dynamic> _$CreateByToJson(CreateBy instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
  'avatar_template': instance.avatarTemplate,
  'animated_avatar': instance.animatedAvatar,
};

Bookmarks _$BookmarksFromJson(Map<String, dynamic> json) => Bookmarks(
  (json['id'] as num?)?.toInt(),
  json['name'] as String?,
  json['reminder_at'] as String?,
  (json['auto_delete_preference'] as num?)?.toInt(),
  (json['bookmarkable_id'] as num?)?.toInt(),
  json['bookmarkable_type'] as String?,
);

Map<String, dynamic> _$BookmarksToJson(Bookmarks instance) => <String, dynamic>{
  'auto_delete_preference': instance.autoDeletePreference,
  'bookmarkable_id': instance.bookmarkableId,
  'bookmarkable_type': instance.bookmarkableType,
  'id': instance.id,
  'name': instance.name,
  'reminder_at': instance.reminderAt,
};

PollsVotes _$PollsVotesFromJson(Map<String, dynamic> json) => PollsVotes(
  votes: (json['votes'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
);

Map<String, dynamic> _$PollsVotesToJson(PollsVotes instance) =>
    <String, dynamic>{'votes': instance.votes};

Polls _$PollsFromJson(Map<String, dynamic> json) => Polls(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  type: json['type'] as String?,
  status: json['status'] as String?,
  public: json['public'] as bool?,
  results: json['results'] as String?,
  options: (json['options'] as List<dynamic>?)
      ?.map((e) => PollOption.fromJson(e as Map<String, dynamic>))
      .toList(),
  voters: (json['voters'] as num?)?.toInt(),
  preloaded_voters: (json['preloaded_voters'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => PollVoter.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
  chart_type: json['chart_type'] as String?,
  title: json['title'] as String?,
  vote: (json['vote'] as List<dynamic>?)?.map((e) => e as String).toList(),
  postId: (json['postId'] as num?)?.toInt(),
);

Map<String, dynamic> _$PollsToJson(Polls instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'status': instance.status,
  'public': instance.public,
  'results': instance.results,
  'options': instance.options,
  'voters': instance.voters,
  'preloaded_voters': instance.preloaded_voters,
  'chart_type': instance.chart_type,
  'title': instance.title,
  'vote': instance.vote,
  'postId': instance.postId,
};

PollOption _$PollOptionFromJson(Map<String, dynamic> json) => PollOption(
  id: json['id'] as String?,
  html: json['html'] as String?,
  votes: (json['votes'] as num?)?.toInt(),
);

Map<String, dynamic> _$PollOptionToJson(PollOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'html': instance.html,
      'votes': instance.votes,
    };

PollVoter _$PollVoterFromJson(Map<String, dynamic> json) => PollVoter(
  id: (json['id'] as num?)?.toInt(),
  username: json['username'] as String?,
  name: json['name'] as String?,
  avatar_template: json['avatar_template'] as String?,
  title: json['title'] as String?,
  animated_avatar: json['animated_avatar'] as String?,
);

Map<String, dynamic> _$PollVoterToJson(PollVoter instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'avatar_template': instance.avatar_template,
  'title': instance.title,
  'animated_avatar': instance.animated_avatar,
};
