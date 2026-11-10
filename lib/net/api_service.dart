import 'package:dio/dio.dart' hide Headers, MultipartFile;
import 'package:linux_do/models/chat_direct.dart';
import 'package:linux_do/models/docs.dart';
import 'package:linux_do/models/follow.dart';
import 'package:linux_do/models/leaderboard.dart';
import 'package:linux_do/models/poll_vote.dart';
import 'package:linux_do/models/request/update_post.dart';
import 'package:linux_do/net/success_response.dart';
import 'package:retrofit/retrofit.dart';
import 'dart:convert';
import '../models/about.dart';
import '../models/activity_stream.dart';
import '../models/birthday.dart';
import '../models/create_post_response.dart';
import '../models/group.dart';
import '../models/image_size.dart';
import '../models/login.dart';
import '../models/post_response.dart';
import '../models/request/user_preferences_request.dart';
import '../models/request/user_request.dart';
import '../models/topic_detail.dart';
import '../models/topic_model.dart';
import '../models/upload_image_response.dart';
import '../models/user.dart';
import '../models/summary.dart';
import '../models/user_action.dart';
import '../models/notification.dart';
import '../models/message.dart';
import '../models/badge_detail.dart';
import '../models/category_data.dart';
import '../models/tag_data.dart';
import '../models/search_result.dart';
import '../models/chat_response.dart';
import '../models/chat_messages_response.dart';
import '../models/user_post.dart';
import 'http_config.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: HttpConfig.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  /// 获取CSRF Token
  @GET('session/csrf')
  Future<void> getCsrfToken();

  /// 登录
  @POST('session')
  Future<void> login(@Body() LoginRequest loginRequest);

  /// 获取首页话题
  @GET("{path}.json")
  Future<TopicListResponse> getTopics(
    @Path('path') String path, [
    @Query("page") int? page = 0,
  ]);

  /// 设置某个话题免打扰
  @POST("t/{id}/notifications")
  @MultiPart()
  Future<dynamic> setTopicMute(
    @Path("id") String id,
    @Part(name: "notification_level") int notificationLevel,
  );

  /// 获取帖子详情 - 首次加载和分页
  @GET("t/{id}{page}.json")
  @DioResponseType(ResponseType.json)
  Future<TopicDetail> getTopicDetail(
    @Path("id") String id, {
    @Path("page") String page = "",
    @Query("track_visit") bool trackVisit = true,
    @Query("forceLoad") bool forceLoad = true,
  });

  /// 获取机器人私信回复详情
  @GET("t/{topic_id}.json")
  Future<TopicDetail> getRobotTopicDetail(
    @Path("topic_id") String topicId, {
    @Query("track_visit") bool trackVisit = true,
    @Query("forceLoad") bool forceLoad = true,
  });

  /// 获取单个帖子内容
  @GET("posts/{post_id}")
  Future<Post> getPostContent(@Path("post_id") String postId);

  /// 获取帖子详情 - 加载指定帖子
  @GET("t/{id}/posts.json")
  @DioResponseType(ResponseType.json)
  Future<TopicDetail> getTopicPosts(
    @Path("id") String id, {
    @Query("post_ids[]") List<String> postIds = const [],
    @Query("include_suggested") bool includeSuggested = true,
  });

  /// 更新帖子阅读时间
  @POST("topics/timings")
  @MultiPart()
  Future<void> updateTopicTiming(
    @Part(name: "topic_id") String topicId,
    @Part(name: "topic_time") String topicTime,
    @Part(name: "timings") Map<String, String> timingsMap, {
    @Header("discourse-background") String background = "true",
    @Header("discourse-logged-in") String loggedIn = "true",
    @Header("discourse-present") String present = "true",
    @Header("x-silence-logger") String silence = "true",
    @Header("Accept") String accept = "application/json, text/plain, */*",
    @Header("Accept-Language")
    String acceptLanguage = "zh-CN,zh;q=0.9,en;q=0.8",
    @Header("X-Requested-With") String requestedWith = "XMLHttpRequest",
    @Header("sec-ch-ua")
    String secChUa =
        "\"Chromium\";v=\"134\", \"Not:A-Brand\";v=\"24\", \"Google Chrome\";v=\"134\"",
    @Header("sec-ch-ua-mobile") String secChUaMobile = "?0",
    @Header("sec-ch-ua-platform") String secChUaPlatform = "\"macOS\"",
  });

  /// 用户信息
  @GET('u/{current}.json')
  Future<UserResponse> getCurrentUser(@Path("current") String current);

  /// 提交更新用户信息
  @PUT('u/{current}.json')
  Future<SuccessResponse<CurrentUser>> updateUser(
    @Path("current") String current,
    @Body() UserRequest userRequest,
  );

  /// 更新头像
  @PUT('u/{current}/preferences/avatar/pick')
  Future<SuccessResponse<dynamic>> updateUserAvatar(
    @Path("current") String current, {
    @Field('type') String type = 'custom',
    @Field('upload_id') int uploadId = 0,
  });

  /// 搜索话题
  @GET('search/query')
  Future<SearchResult> searchTopic({
    @Query('term') String term = 'status:public',
    @Query('search_for_id') bool searchForId = true,
    @Query('type_filter') String typeFilter = 'topic',
    @Query('restrict_to_archetype') String restrictToArchetype = 'regular',
  });

  //关联话题
  @GET('u/{username}/feature-topic')
  Future<SuccessResponse<dynamic>> relatedTopics(
    @Path('username') String username, {
    @Query('topic_id') int? topicId,
  });

  /// 清除关联话题
  @PUT('u/{username}/clear-featured-topic')
  Future<SuccessResponse<dynamic>> clearRelatedTopics(
    @Path('username') String username,
  );

  /// 提交更新用户资料
  @PUT('u/{current}.json')
  Future<SuccessResponse<CurrentUser>> updateUserPreferences(
    @Path('current') String current,
    @Body() UserPreferencesRequest userPreferencesRequest,
  );

  /// 查询用户卡片数据
  @GET('u/{username}/card.json')
  Future<UserResponse> getUserCard(
    @Path('username') String username, {
    @Query('include_post_count_for') int? includePostCountFor,
  });

  /// 操作用户认可
  @PUT('category-experts/endorse/{username}.json')
  Future<dynamic> endorseUserCategory(
    @Path('username') String username,
    @Field('categoryIds') List<int> categoryIds,
  );

  /// 关注用户
  @PUT('follow/{username}.json')
  Future<SuccessResponse<dynamic>> followUser(
    @Path('username') String username,
  );

  /// 取消关注用户
  @DELETE('follow/{username}.json')
  Future<SuccessResponse<dynamic>> unfollowUser(
    @Path('username') String username,
  );

  /// 查询用户分类信息
  @GET('category-experts/endorsable-categories/{username}.json')
  Future<CategoryList> getUserCategories(@Path('username') String username);

  /// 总结数据
  @GET('u/{current}/summary.json')
  Future<SummaryResponse> getUserSummary(@Path("current") String current);

  /// 用户活动
  @GET('user_actions.json')
  Future<UserActionResponse> getUserActions(
    @Query("username") String username,
    @Query("offset") int offset,
    @Query("filter") String filter,
  );

  /// 通知
  @GET('notifications')
  Future<NotificationResponse> getNotifications(
    @Query("username") String username,
    @Query("limit") int limit,
    @Query("filter") String filter,
  );

  /// 消息/私信
  @GET('topics/private-messages/{username}.json')
  Future<MessageResponse> getMessages(@Path("username") String username);

  /// 用户徽章
  @GET('user-badges/{current}.json')
  Future<BadgeDetailResponse> getUserBadges(
    @Path("current") String current, [
    @Query("only_listable") bool onlyListable = true,
    @Query("onlyListable") bool listable = true,
  ]);

  /// 全部徽章
  @GET('badges.json')
  Future<BadgeDetailResponse> getBadges([
    @Query("only_listable") bool onlyListable = true,
    @Query("onlyListable") bool listable = true,
  ]);

  /// 获取回复草稿
  @GET('drafts/topic_{topic_id}.json')
  Future<void> getTopicDraft(@Path('topic_id') String topicId);

  /// 获取编辑器信息
  @GET('composer_messages')
  Future<void> getComposerMessages(
    @Query('composer_action') String composerAction,
    @Query('topic_id') String topicId,
  );

  /// 更新在线状态
  @PUT('presence/update')
  Future<void> updateChannelPresence(
    @Field('client_id') String clientId,
    @Field('present_channels[]') String channel,
  );

  /// 保存草稿
  @POST('drafts.json')
  Future<void> saveDraft(
    @Field('draft_key') String draftKey,
    @Field('sequence') int sequence,
    @Field('data') String data,
    @Field('owner') String owner,
    @Field('force_save') bool forceSave,
  );

  /// 发送回复
  @POST('posts.json')
  @FormUrlEncoded()
  Future<PostResponse> replyPost(
    @Field('topic_id') String topicId,
    @Field('raw') String content,
    @Field('nested_post') bool nestedPost,
    @Field('archetype') String archetype,
    @Field('category') String category, {
    @Field('reply_to_post_number') int? replyToPostNumber,
  });

  /// 点赞帖子
  @PUT('discourse-reactions/posts/{post_id}/custom-reactions/heart/toggle.json')
  Future<Post> togglePostLike(@Path('post_id') String postId);

  /// 删除帖子
  @DELETE('posts/{post_id}')
  Future<void> deletePost(
    @Path('post_id') String postId, {
    @Query('context') String? context,
  });

  /// 获取删除的帖子
  @GET('posts/{post_id}')
  Future<Post> getDeletedPosts(@Path('post_id') String postId);

  @GET('categories.json')
  Future<CategoryListResponse> getCategories();

  /// 获取分类的权限等级统计
  @GET('c/{id}/l/{level}.json')
  Future<TopicListResponse> getCategoryLevelStats(
    @Path('id') int categoryId,
    @Path('level') int level,
  );

  @GET('tags/filter/search')
  Future<TagResponse> getTags(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('categoryId') int categoryId,
    @Query('filterForInput') bool filterForInput,
  );

  /// 上传图片
  @POST('uploads.json')
  @MultiPart()
  Future<UploadImageResponse> uploadImage(
    @Query('client_id') String clientId,
    @Body() FormData formData,
  );

  /// 发布新主题
  @POST('posts')
  @FormUrlEncoded()
  Future<CreatePostResponse> createPost({
    @Field('title') String? title,
    @Field('raw') required String content,
    @Field('category') int? categoryId,
    @Field('unlist_topic') bool? unlistTopic = false,
    @Field('is_warning') bool? isWarning = false,
    @Field('archetype') String? archetype = 'regular',
    @Field('typing_duration_msecs') int typingDurationMsecs = 1000,
    @Field('composer_open_duration_msecs') int composerOpenDurationMsecs = 1000,
    @Field('nested_post') bool nestedPost = true,
    @Field('tags[]') List<String>? tags,
    @Field('image_sizes') Map<String, ImageSize>? imageSizes,
    @Field('target_recipients') String? targetRecipients,
    @Field('meta_data[ai_persona_id]') int? aiPersonaId,
    @Field('topic_id') int? topicId,
  });

  /// 修改主题meta_data[ai_persona_id]: 8
  @PUT('posts/{id}')
  @FormUrlEncoded()
  Future<CreatePostResponse> updateTopic(
    @Path('id') String id,
    @Body() UpdatePostRequest request,
  );

  /// 搜索
  @GET('search')
  Future<SearchResult> search({
    @Query('q') required String query,
    @Query('page') int? page,
  });

  /// 获取聊天列表
  @GET('chat/api/me/channels')
  Future<ChatResponse> getChannels();

  /// 获取频道消息
  @GET('chat/api/channels/{channelId}/messages')
  Future<ChatMessagesResponse> getChannelMessages(
    @Path('channelId') int channelId, {
    @Query('page_size') int? pageSize,
    @Query('target_message_id') int? targetMessageId,
    @Query('direction') String? direction,
    @Query('position') String? position,
  });

  /// 标记频道消息为已读
  @PUT('chat/api/channels/{channelId}/read')
  Future<dynamic> markChannelAsRead(
    @Path('channelId') int channelId,
    @Query('message_id') int messageId,
  );

  /// 获取直接消息频道
  @POST('chat/api/direct-message-channels.json')
  Future<ChatDirect> getDirectChannel(
    @Field('usernames') String usernames,
    @Field('loadChat') bool loadChat,
    @Field('force_create') bool forceCreate,
  );

  /// 发送消息
  @POST('chat/{channelId}')
  @FormUrlEncoded()
  Future<dynamic> sendMessage(
    @Path('channelId') int channelId,
    @Field('message') String message,
    @Field('staged_id') String? stagedId,
  );

  /// 更改在线状态
  @PUT('u/{current}.json')
  Future<UserResponse> updatePresence(
    @Path('current') String current,
    @Field('hide_presence') bool hidePresence,
  );

  /// 更新自定义状态
  @PUT('user-status.json')
  Future<SuccessResponse<dynamic>> updateUserStatus(
    @Field('description') String description, {
    @Field('emoji') String emoji = 'speech_balloon',
  });

  /// 删除自定义状态
  @DELETE('user-status.json')
  Future<SuccessResponse<dynamic>> deleteUserStatus();

  /// 获取我的帖子列表
  @GET('posted.json')
  Future<TopicListResponse> getMyPosted([@Query("page") int? page = 1]);

  /// 获取我的书签列表
  @GET('bookmarks.json')
  Future<TopicListResponse> getMyBookmarks([@Query("page") int? page]);

  /// 获取文档列表
  @GET('docs.json')
  Future<Docs> getDocs([
    @Query("page") int? page,
    @Query("tags") String? tag,
    @Query("category") String? category,
  ]);

  /// 获取分类列表
  @GET('c/resource/{categoryId}/l/latest.json')
  Future<TopicListResponse> getCategoriesTopics(
    @Path('categoryId') int categoryId, {
    @Query('page') int? page,
    @Query('filter') String? filter = 'default',
  });

  /// 根据tag获取帖子列表
  @GET('tag/{tag}/l/latest.json')
  Future<TopicListResponse> getTopicsByTag(
    @Path('tag') String tag, {
    @Query('page') int? page,
  });

  /// 获取排行榜
  @GET('leaderboard{categoryId}')
  Future<LeaderboardResponse> getLeaderboard({
    @Path('categoryId') String categoryId = '',
    @Query('period') String period = 'all',
    @Query('page') int? page,
  });

  /// 离开群组
  @DELETE('groups/{group_id}/leave.json')
  Future<void> leaveGroup(@Path('group_id') int groupId);

  /// 加入群组
  @PUT('groups/{group_id}/join.json')
  Future<void> joinGroup(@Path('group_id') int groupId);

  /// 获取群组列表
  @GET('groups')
  Future<GroupResponse> getGroups();

  /// 获取活动列表
  @GET('discourse-post-event/events')
  Future<ActivityStreamResponse> getEventStream();

  /// 获取生日列表
  @GET('cakeday/birthdays')
  Future<BirthdayResponse> getBirthdays([
    @Query('filter') String? filter,
    @Query('page') int? page,
    @Query('month') int? month,
  ]);

  /// 添加书签
  @POST('bookmarks.json')
  Future<dynamic> addBookmark({
    @Field('auto_delete_preference') int? autoDeletePreference = 3,
    @Field('bookmarkable_id') int? bookmarkableId,
    @Field('bookmarkable_type') String? bookmarkableType = 'Post',
    @Field('reminder_at') String? reminderAt,
  });

  /// 删除书签
  @DELETE('bookmarks/{topic_id}.json')
  Future<dynamic> deleteBookmark(@Path('topic_id') String topicId);

  /// 关于我们数据
  @GET('about.json')
  Future<AboutResponse> getAbout();

  /// 解除账户关联
  @DELETE('auth/{type}/revoke.json')
  Future<SuccessResponse<dynamic>> unlinkAccount(
    @Path('username') String username,
    @Path('type') String type,
  );

  /// 撤销认证令牌
  @POST('u/{username}/preferences/revoke-auth-token')
  Future<SuccessResponse<dynamic>> revokeAuthToken(
    @Path('username') String username,
    @Field('token_id') int id,
  );

  /// 撤销所有认证令牌
  @DELETE('user-auth-tokens')
  Future<SuccessResponse<dynamic>> revokeAllAuthTokens();

  /// 发送重置密码的电子邮件
  @POST('session/forgot_password')
  Future<SuccessResponse<dynamic>> sendResetPasswordEmail(
    @Field('login') String login,
  );

  /// 请求数据导出
  @POST('export_csv/export_entity.json')
  Future<SuccessResponse<dynamic>> requestDataExport({
    @Field('entity') String entity = 'user_archive',
  });

  /// 更新政策接受状态
  @PUT('policy/{action}')
  Future<SuccessResponse<dynamic>> updatePolicyAccepted(
    @Path('action') String action,
    @Field('post_id') String postId,
  );

  /// 获取用户关注者列表
  @GET('u/{username}/follow/following')
  Future<List<Follow>> getFollowing(
    @Path('username') String username, {
    @Query('offset') int? offset,
    @Query('limit') int? limit,
  });

  /// 获取用户关注者列表
  @GET('u/{username}/follow/followers')
  Future<List<Follow>> getFollowers(
    @Path('username') String username, {
    @Query('offset') int? offset,
    @Query('limit') int? limit,
  });

  /// 获取用户的帖子（动态）
  @GET('follow/posts/{username}')
  Future<UserPostResponse> getUserPosts(
    @Path('username') String username, {
    @Query('created_before') String? createdBefore,
  });

  /// 删除话题
  @DELETE('t/{topic_id}.json')
  Future<SuccessResponse<dynamic>> deleteTopic(
    @Path('topic_id') String topicId,
  );

  /// 查询回复信息
  @GET('posts/{id}/replies')
  Future<PostRepliesResponse> getPostReplies(
    @Path('id') String id, {
    @Query('after') int? after = 1,
  });

  /// 查询帖子链接行
  @GET('posts/by_number/{topic_id}/{post_number}')
  Future<Post> getPostLinkRow(
    @Path('topic_id') String topicId,
    @Path('post_number') String postNumber,
  );

  /// 提交投票
  @PUT('polls/vote')
  Future<PollVote> submitVote(
    @Field('poll_name') String pollName,
    @Field('options[]') List<String> options, {
    @Field('post_id') int? postId,
    @Header("content-type")
    String contentType = "application/x-www-form-urlencoded",
  });

  /// 获取投票者列表
  @GET('polls/voters.json')
  Future<PollVotersResponse> getPollVoters({
    @Query('post_id') int? postId,
    @Query('poll_name') String? pollName,
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('option_id') String? optionId,
  });
}
