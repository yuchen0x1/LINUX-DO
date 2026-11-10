import 'package:json_annotation/json_annotation.dart';
import 'topic_detail.dart';

part 'post_response.g.dart';

@JsonSerializable()
class PostResponse {
  final String action;
  final PostDetail post;
  final bool success;

  PostResponse({
    required this.action,
    required this.post,
    required this.success,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) =>
      _$PostResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PostResponseToJson(this);
}

@JsonSerializable()
class PostDetail extends Post {
  final String? raw;
  @override
  @JsonKey(name: 'can_edit')
  final bool? canEdit;
  @override
  @JsonKey(name: 'can_delete')
  final bool? canDelete;
  @override
  @JsonKey(name: 'can_recover')
  final bool? canRecover;
  @override
  @JsonKey(name: 'can_see_hidden_post')
  final bool? canSeeHiddenPost;
  @override
  @JsonKey(name: 'can_wiki')
  final bool? canWiki;
  @override
  final bool? admin;
  @override
  final bool? staff;
  @JsonKey(name: 'draft_sequence')
  final int? draftSequence;
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;
  @JsonKey(name: 'user_deleted')
  final bool? userDeleted;
  @JsonKey(name: 'edit_reason')
  final String? editReason;
  @JsonKey(name: 'can_view_edit_history')
  final bool? canViewEditHistory;
  @override
  final bool? wiki;
  @JsonKey(name: 'mentioned_users')
  final List<dynamic>? mentionedUsers;
  @JsonKey(name: 'post_url')
  final String? postUrl;
  @JsonKey(name: 'animated_avatar')
  final String? animatedAvatar;
  @JsonKey(name: 'user_cakedate')
  final String? userCakedate;
  @JsonKey(name: 'user_birthdate')
  final String? userBirthdate;
  @override
  final Map<String, dynamic>? event;
  @JsonKey(name: 'category_expert_approved_group')
  final String? categoryExpertApprovedGroup;
  @JsonKey(name: 'needs_category_expert_approval')
  final bool? needsCategoryExpertApproval;
  @JsonKey(name: 'can_manage_category_expert_posts')
  final bool? canManageCategoryExpertPosts;
  @JsonKey(name: 'post_folding_status')
  final String? postFoldingStatus;
  @override
  final List<dynamic>? reactions;
  @override
  @JsonKey(name: 'current_user_reaction')
  final Map<String, dynamic>? currentUserReaction;
  @JsonKey(name: 'current_user_used_main_reaction')
  final bool? currentUserUsedMainReaction;
  @JsonKey(name: 'user_signature')
  final String? userSignature;
  @JsonKey(name: 'can_accept_answer')
  final bool? canAcceptAnswer;
  @JsonKey(name: 'can_unaccept_answer')
  final bool? canUnacceptAnswer;
  @JsonKey(name: 'accepted_answer')
  final bool? acceptedAnswer;
  @JsonKey(name: 'topic_accepted_answer')
  final bool? topicAcceptedAnswer;

  PostDetail({
    required int id,
    String? name,
    String? username,
    int? userId,
    String? avatarTemplate,
    String? createdAt,
    String? cooked,
    int? postNumber,
    int? postType,
    String? updatedAt,
    int? replyCount,
    int? quoteCount,
    int? incomingLinkCount,
    int? reads,
    double? score,
    bool? yours,
    int? topicId,
    String? topicSlug,
    String? displayUsername,
    String? primaryGroupName,
    bool? hidden,
    int? trustLevel,
    String? userTitle,
    bool? bookmarked,
    List<ActionSummary>? actionsSummary,
    int? replyToPostNumber,
    int? reactionUsersCount,
    int? postsCount,
    int? readersCount,
    bool? moderator,
    this.raw,
    this.canEdit,
    this.canDelete,
    this.canRecover,
    this.canSeeHiddenPost,
    this.canWiki,
    this.admin,
    this.staff,
    this.draftSequence,
    this.deletedAt,
    this.userDeleted,
    this.editReason,
    this.canViewEditHistory,
    this.wiki,
    this.mentionedUsers,
    this.postUrl,
    this.animatedAvatar,
    this.userCakedate,
    this.userBirthdate,
    this.event,
    this.categoryExpertApprovedGroup,
    this.needsCategoryExpertApproval,
    this.canManageCategoryExpertPosts,
    this.postFoldingStatus,
    this.reactions,
    this.currentUserReaction,
    this.currentUserUsedMainReaction,
    this.userSignature,
    this.canAcceptAnswer,
    this.canUnacceptAnswer,
    this.acceptedAnswer,
    this.topicAcceptedAnswer,
  }) : super(
         name: name,
         username: username,
         userId: userId,
         avatarTemplate: avatarTemplate,
         createdAt: createdAt,
         cooked: cooked,
         postNumber: postNumber,
         postType: postType,
         updatedAt: updatedAt,
         replyCount: replyCount,
         quoteCount: quoteCount,
         incomingLinkCount: incomingLinkCount,
         reads: reads,
         score: score,
         yours: yours,
         topicId: topicId,
         topicSlug: topicSlug,
         displayUsername: displayUsername,
         primaryGroupName: primaryGroupName,
         hidden: hidden,
         trustLevel: trustLevel,
         userTitle: userTitle,
         bookmarked: bookmarked,
         actionsSummary: actionsSummary,
         replyToPostNumber: replyToPostNumber,
         reactionUsersCount: reactionUsersCount ?? 0,
         postsCount: postsCount,
         readersCount: readersCount,
         moderator: moderator,
         id: id,
       );

  factory PostDetail.fromJson(Map<String, dynamic> json) =>
      _$PostDetailFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PostDetailToJson(this);
}
