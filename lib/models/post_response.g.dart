// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostResponse _$PostResponseFromJson(Map<String, dynamic> json) => PostResponse(
  action: json['action'] as String,
  post: PostDetail.fromJson(json['post'] as Map<String, dynamic>),
  success: json['success'] as bool,
);

Map<String, dynamic> _$PostResponseToJson(PostResponse instance) =>
    <String, dynamic>{
      'action': instance.action,
      'post': instance.post,
      'success': instance.success,
    };

PostDetail _$PostDetailFromJson(Map<String, dynamic> json) =>
    PostDetail(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String?,
        username: json['username'] as String?,
        userId: (json['userId'] as num?)?.toInt(),
        avatarTemplate: json['avatarTemplate'] as String?,
        createdAt: json['createdAt'] as String?,
        cooked: json['cooked'] as String?,
        postNumber: (json['postNumber'] as num?)?.toInt(),
        postType: (json['postType'] as num?)?.toInt(),
        updatedAt: json['updatedAt'] as String?,
        replyCount: (json['replyCount'] as num?)?.toInt(),
        quoteCount: (json['quoteCount'] as num?)?.toInt(),
        incomingLinkCount: (json['incomingLinkCount'] as num?)?.toInt(),
        reads: (json['reads'] as num?)?.toInt(),
        score: (json['score'] as num?)?.toDouble(),
        yours: json['yours'] as bool?,
        topicId: (json['topicId'] as num?)?.toInt(),
        topicSlug: json['topicSlug'] as String?,
        displayUsername: json['displayUsername'] as String?,
        primaryGroupName: json['primaryGroupName'] as String?,
        hidden: json['hidden'] as bool?,
        trustLevel: (json['trustLevel'] as num?)?.toInt(),
        userTitle: json['userTitle'] as String?,
        bookmarked: json['bookmarked'] as bool?,
        actionsSummary: (json['actionsSummary'] as List<dynamic>?)
            ?.map((e) => ActionSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
        replyToPostNumber: (json['replyToPostNumber'] as num?)?.toInt(),
        reactionUsersCount: (json['reactionUsersCount'] as num?)?.toInt(),
        postsCount: (json['postsCount'] as num?)?.toInt(),
        readersCount: (json['readersCount'] as num?)?.toInt(),
        moderator: json['moderator'] as bool?,
        raw: json['raw'] as String?,
        canEdit: json['can_edit'] as bool?,
        canDelete: json['can_delete'] as bool?,
        canRecover: json['can_recover'] as bool?,
        canSeeHiddenPost: json['can_see_hidden_post'] as bool?,
        canWiki: json['can_wiki'] as bool?,
        admin: json['admin'] as bool?,
        staff: json['staff'] as bool?,
        draftSequence: (json['draft_sequence'] as num?)?.toInt(),
        deletedAt: json['deleted_at'] as String?,
        userDeleted: json['user_deleted'] as bool?,
        editReason: json['edit_reason'] as String?,
        canViewEditHistory: json['can_view_edit_history'] as bool?,
        wiki: json['wiki'] as bool?,
        mentionedUsers: json['mentioned_users'] as List<dynamic>?,
        postUrl: json['post_url'] as String?,
        animatedAvatar: json['animated_avatar'] as String?,
        userCakedate: json['user_cakedate'] as String?,
        userBirthdate: json['user_birthdate'] as String?,
        event: json['event'] as Map<String, dynamic>?,
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
        currentUserUsedMainReaction:
            json['current_user_used_main_reaction'] as bool?,
        userSignature: json['user_signature'] as String?,
        canAcceptAnswer: json['can_accept_answer'] as bool?,
        canUnacceptAnswer: json['can_unaccept_answer'] as bool?,
        acceptedAnswer: json['accepted_answer'] as bool?,
        topicAcceptedAnswer: json['topic_accepted_answer'] as bool?,
      )
      ..replayList = (json['replayList'] as List<dynamic>?)
          ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$PostDetailToJson(PostDetail instance) =>
    <String, dynamic>{
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
      'userTitle': instance.userTitle,
      'bookmarked': instance.bookmarked,
      'actionsSummary': instance.actionsSummary,
      'moderator': instance.moderator,
      'userId': instance.userId,
      'hidden': instance.hidden,
      'trustLevel': instance.trustLevel,
      'reactionUsersCount': instance.reactionUsersCount,
      'replayList': instance.replayList,
      'raw': instance.raw,
      'can_edit': instance.canEdit,
      'can_delete': instance.canDelete,
      'can_recover': instance.canRecover,
      'can_see_hidden_post': instance.canSeeHiddenPost,
      'can_wiki': instance.canWiki,
      'admin': instance.admin,
      'staff': instance.staff,
      'draft_sequence': instance.draftSequence,
      'deleted_at': instance.deletedAt,
      'user_deleted': instance.userDeleted,
      'edit_reason': instance.editReason,
      'can_view_edit_history': instance.canViewEditHistory,
      'wiki': instance.wiki,
      'mentioned_users': instance.mentionedUsers,
      'post_url': instance.postUrl,
      'animated_avatar': instance.animatedAvatar,
      'user_cakedate': instance.userCakedate,
      'user_birthdate': instance.userBirthdate,
      'event': instance.event,
      'category_expert_approved_group': instance.categoryExpertApprovedGroup,
      'needs_category_expert_approval': instance.needsCategoryExpertApproval,
      'can_manage_category_expert_posts': instance.canManageCategoryExpertPosts,
      'post_folding_status': instance.postFoldingStatus,
      'reactions': instance.reactions,
      'current_user_reaction': instance.currentUserReaction,
      'current_user_used_main_reaction': instance.currentUserUsedMainReaction,
      'user_signature': instance.userSignature,
      'can_accept_answer': instance.canAcceptAnswer,
      'can_unaccept_answer': instance.canUnacceptAnswer,
      'accepted_answer': instance.acceptedAnswer,
      'topic_accepted_answer': instance.topicAcceptedAnswer,
    };
