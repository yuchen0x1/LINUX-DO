import 'package:linux_do/net/http_config.dart';

class AppConst {
  /// L 站名称
  static const String siteName = 'LINUX DO';

  /// 我们的口号
  static const String slogan = '真诚、友善、团结、专业，\n共建你我引以为荣之社区。';

  /// 顶部信息
  static const String topInfo = '真诚、友善、团结、专业，共建你我引以为荣之社区。《常见问题解答》';

  /// 顶部信息
  static const String sloganEn = 'Sincere, friendly, united, and professional.';

  /// 通用提示
  static const String commonTip = '提示';
  static const updateSuccess = '更新成功';

  /// 配置成功
  static const configSuccess = '配置成功';

  /// 配置失败
  static const configFailed = '配置失败';

  /// 更新失败
  static const updateFailed = '更新失败';

  /// 取消
  static const cancel = '取消';

  /// 确定
  static const confirm = '确定';

  /// 支持的语言
  static const supportedLanguages = ['en', 'zh'];

  /// 常见问题
  static const faq = 'faq';

  static const open = '打开';

  static const close = '关闭';

  /// 用户协议
  static const terms = 'assets/html/terms-service.html';

  /// 隐私政策
  static const privacy = 'assets/html/privacy-policy.html';

  // 收藏菜单类别列表
  static const bookmarkCategories = [
    '开发调优',
    '文档共建',
    '非我莫属',
    '扬帆起航',
    '福利羊毛',
    '运营反馈',
    '资源荟萃',
    '跳蚤市场',
    '读书成诗',
    '前沿快讯',
    '搞七捻三',
    '深海幽域'
  ];

  /// 抽屉菜单
  static const drawerMenu = _DrawerMenu();

  /// 各种状态的提示
  static const stateHint = _StateConst();

  /// 标识常量
  static final identifier = _Identifier();

  /// 登录页面相关
  static const login = _LoginConst();

  /// 设置相关
  static const settings = _Settings();

  /// 帖子相关
  static const posts = _Posts();

  /// 发帖相关
  static const createPost = _CreatePost();

  static const chat = _Chat();

  /// 分类主题相关
  static const categoryTopics = _CategoryTopics();

  /// 排行榜相关
  static const leaderboard = _Leaderboard();

  /// 群组相关
  static const group = _Group();

  /// 活动相关
  static const activity = _Activity();

  /// 生日相关
  static const _Birthday birthday = _Birthday();

  /// 用户相关
  static const user = _User();
}

/// 抽屉菜单文本
class _DrawerMenu {
  const _DrawerMenu();

  String get topics => '话题';
  String get myDrafts => '草稿';
  String get externalLinks => '外部链接';
  String get categories => '类别';
  String get tags => '标签';
  String get messages => '消息';
  String get channels => '频道';
  String get inbox => '收件箱';
  String get regularChannel => '常规频道';
  String get telegram => 'Telegram';
  String get telegramChannel => 'Channel';
  String get connect => 'Connect';
  String get status => 'Status';
  String get lottery => 'Lottery';

  // 类别
  String get devOptimization => '开发调优';
  String get docBuilding => '文档共建';
  String get notMine => '非我莫属';
  String get sailAway => '扬帆起航';
  String get benefits => '福利羊毛';
  String get operationFeedback => '运营反馈';
  String get resources => '资源荟萃';
  String get fleaMarket => '跳蚤市场';
  String get readingPoetry => '读书成诗';
  String get frontierNews => '前沿快讯';
  String get pickAndChoose => '摘七拾三';
  String get deepSea => '深海幽域';

  // 标签
  String get essentialPosts => '精华神帖';
  String get ai => '人工智能';
  String get announcements => '公告';
  String get qa => '快问快答';

  String get statusUrl => 'https://status.${HttpConfig.domain}';
  String get connectUrl => 'https://connect.${HttpConfig.domain}';
  String get lotteryUrl => 'https://lottery.${HttpConfig.domain}';
  String get channelUrl => 'https://t.me/linux_do_channel';
  String get jaTGUrl => 'https://t.me/ja_netfilter_group';
}

class _StateConst {
  const _StateConst();

  String get error => '出错啦~';
  String get empty => '暂无数据哦~';
}

/// 标识常量
class _Identifier {
  const _Identifier();

  String get token => 'token';
  String get cfClearance => 'cfClearance';
  String get sessionCookie => '_forum_session';
  String get userInfo => 'userInfo';
  String get theme => 'theme';
  String get language => 'language';
  String get isFirst => 'isFirst';
  String get username => 'username';
  String get name => 'name';
  String get userId => 'userId';
  String get isLogin => 'isLogin';
  String get csrfToken => 'csrfToken';
  String get clientId => 'clientId';

  String get themeColor => 'themeColor';
  String get postFontSize => 'postFontSize';
  String get replyFontSize => 'replyFontSize';
  String get listDensity => 'list_density';

  String get browserTips => 'browserTips';
  String get chatHintDontShow => 'chatHintDontShow';

  String get isAnonymousMode => 'isAnonymousMode';

  String get simplified => 'simplified';
}

/// 登录页面文本
class _LoginConst {
  const _LoginConst();

  String get title => '登录';
  String get scanLogin => '扫码登录';
  String get webTitle => '网页授权登录';
  String get greetingPhrase => '欢迎来到';
  String get accountHint => '请输入账号';
  String get passwordHint => '请输入密码';
  String get forgotPassword => '我忘记密码了';
  String get noAccount => '还没有账号？';
  String get register => '立即注册';
  String get agreement => '登录即代表同意';
  String get serviceAgreement => '服务协议';
  String get and => '和';
  String get privacyPolicy => '隐私政策';
  String get anonymousMode => '使用游客模式浏览';

  // 提示信息
  String get emptyUsername => '请输入账号';
  String get emptyPassword => '请输入密码';
  String get loginFailedTitle => '登录失败';
  String get loginFailedMessage => '请检查网络连接或稍后重试';
  String get networkError => '请检查网络连接或稍后重试';
  String get userInfoError => '用户信息获取失败';
  String get loginSuccessTitle => '登录成功';
  String get welcomeBack => '欢迎回来';
  String get notImplemented => '此功能暂未开发';
  String get registerTip => '请先前往${AppConst.siteName}站点注册';

  // 代理服务器相关
  String get proxyServer => '代理服务器';
  String get proxyServerHint => '例如: https://proxy.example.com';
  String get inputProxyServer => '请输入代理服务器地址';
  String get save => '保存';
  String get cancel => '取消';
  String get clearProxy => '清除代理';
  String get noProxy => '未设置代理';
}

/// 设置相关
class _Settings {
  const _Settings();

  String get title => '设置';
  String get accountAndProfile => '账号与个人资料';
  String get accountSettings => '账号设置';
  String get security => '安全设置';
  String get editProfile => '编辑资料';
  String get emailSettings => '邮箱设置';
  String get dataExport => '数据导出';
  String get notificationsAndPrivacy => '通知与隐私';
  String get notifications => '通知设置';
  String get tracking => '跟踪';
  String get doNotDisturb => '免打扰设置';
  String get anonymousMode => '匿名模式';
  String get appearance => '外观';
  String get darkMode => '深色模式';
  String get themeSystem => '跟随系统';
  String get themeLight => '浅色模式';
  String get themeDark => '深色模式';
  String get themeAmoled => 'AMOLED 纯黑';
  String get themeCustom => '自定义主题';
  String get fontSize => '字体大小';
  String get helpAndSupport => '帮助与支持';
  String get about => '关于 ${AppConst.siteName}';
  String get faq => '常见问题';
  String get terms => '服务条款';
  String get privacy => '隐私政策';
  String get logout => '退出';
  String get login => '去登录';
  String get logoutConfirmTitle => '确认退出';
  String get logoutConfirmMessage => '确定要退出登录吗？';
  String get cancel => '取消';
  String get confirm => '确定';
  String get status => '自定义的状态,为空则删除';
  String get themeColor => '主题色';
  String get other => '其他';
  String get browserTips => '浏览器提示';
  String get save => '保存';
  String get change => '更换';
  String get none => '无';
  String get updateNow => '立即更新';
  String get cancelUpdate => '暂不更新';

  // 编辑资料
  String get basicInfo => '基本信息';
  String get contact => '联系方式';
  String get linkedAccounts => '关联账户';
  String get name => '姓名';
  String get username => '用户名';
  String get userTitle => '头衔';
  String get email => '电子邮件';
  String get backupEmail => '备用邮箱';
  String get inputName => '请输入姓名';
  String get usernameNotEditable => '用户名不可修改';
  String get inputTitle => '请输入头衔';
  String get emailNotEditable => '主邮箱不可修改';
  String get inputBackupEmail => '请输入备用邮箱';
  String get link => '关联';
  String get unlink => '解除';
  String get unknownAccount => '未知账户';
  String get noBadge => '无';

  String get deviceHistory => '设备登录历史';
  String get password => '密码';
  String get currentDevice => '当前设备';
  String get lastSeen => '最后使用';
  String get location => '位置';
  String get browser => '浏览器';
  String get device => '设备';
  String get operatingSystem => '操作系统';
  String get logoutAll => '退出所有设备';
  String get logoutOthers => '退出其他设备';
  String get logoutConfirm => '确认退出？';
  String get logoutAllConfirm => '确认退出所有设备？';
  String get logoutOthersConfirm => '确认退出其他设备？';
  String get active => '当前设备';
  String get inactive => '离线';
  String get sendResetEmail => '发送重置密码邮件';
  String get sendEmailSuccess => '邮件发送成功';
  String get sendEmailFailed => '邮件发送失败';

  String get profile => '个人资料';
  String get introduction => '个人简介';
  String get introductionHint => '介绍一下你自己...';
  String get timezone => '时区';
  String get useCurrentTimezone => '使用当前时区';
  String get website => '个人网站';
  String get websiteHint => '输入有效的URL';
  String get profileTitle => '个人头衔';
  String get profileTitleHint => '设置你的个人头衔';
  String get cardBackground => '用户卡片背景';
  String get cardBackgroundHint => '上传背景图片';
  String get featuredTopic => '精选主题';
  String get selectNewTopic => '选择新主题';
  String get topicLinkHint => '输入主题链接';
  String get cardBadge => '用户卡片徽章';
  String get birthDate => '生日';
  String get region => '所在地';
  String get useCurrentRegion => '使用当前位置';
  String get enableSignature => '启用签名';
  String get signatureHint => '输入有效的URL';
  String get mySignature => '我的签名';
  String get imageUrl => '图片URL';
  String get telegramNotification => 'Telegram 通知';
  String get telegramHint => '输入机器人给你的 Chat ID';

  String get dataExportMessage => '您确定要下载您的帐户活动和偏好设置的归档吗？';
  String get dataExportSuccess => '数据导出成功';
  String get dataExportFailed => '数据导出失败';

  String get emailSettingsTitle => '电子邮件设置';
  String get personalMessage => '个人消息';
  String get mentionsAndReplies => '提及和回复';
  String get watchingCategory => '关注的类别';
  String get policyReview => '策略审核';
  String get activitySummary => '活动总结';
  String get emailSettingsTip => '只有在过去 10 分钟内没有见到您，我们才会向您发送电子邮件。';
  String get includeReplies => '在电子邮件底部包含以前的回复';
  String get includeNewUsers => '在总结电子邮件中包含来自新用户的内容';
  String get summary => '当我不访问这里时，向我发送热门话题和回复的电子邮件总结';
  String get always => '始终';
  String get whenAway => '只在离开时';
  String get never => '从不';

  // 通知设置
  String get notificationSettingsTitle => '通知设置';
  String get notificationWhenLiked => '被赞时通知';
  String get notificationWhenFollowed => '允许其他人关注我';
  String get notificationWhenUserFollowed => '当用户关注我时通知我';
  String get notificationWhenIFollow => '当我关注用户时通知他们';
  String get notificationWhenReplied => '当我关注的人回复时通知我';
  String get notificationWhenTopicCreated => '当我关注的人创建话题时通知我';
  String get notificationSchedule => '接收指定话题提醒的频率';
  String get notificationTip =>
      '注意：您必须须在使用的每个浏览器上更改此设置。如果您从用户菜单暂停通知，则无论此设置如何，所有通知都将被禁用。';

  String get ignoredUsers => '已忽略的用户';
  String get noIgnoredUsers => '您没有忽略任何用户';
  String get addIgnoredUser => '添加忽略用户';
  String get inputIgnoredUsername => '请输入要忽略的用户名';
  String get duration => '持续时间';
  String get dndSettingsTitle => '已设为免打扰';
  String get dndSettingsDescription => '禁止来自这些用户的所有帖子、消息、通知、个人消息和聊天直接消息。';
  String get allowPersonalMessages => '允许个人消息';
  String get allowChatMessages => '允许聊天消息';
  String get messageSettingsTitle => '消息';
  String get messageSettingsDescription => '禁止来自这些用户的所有通知、个人消息和聊天直接消息。';
  String get allowOthersMessage => '允许其他用户向我发送个人消息和聊天直接消息';
  String get addSuccess => '添加成功';
  String get addFailed => '添加失败';
  String get removeSuccess => '移除成功';
  String get removeFailed => '移除失败';
  String get saveSuccess => '保存成功';
  String get saveFailed => '保存失败';
  String get selectUserToBlock => '请选择要屏蔽的用户';
  String get loadSettingsFailed => '加载设置失败';

  // Tracking Settings
  String get trackingInDev => '开发中';
  String get enableTracking => '启用跟踪';
  String get enableTrackingDesc => '允许收集使用数据以改善您的体验';
  String get trackLocation => '位置信息';
  String get trackLocationDesc => '允许访问您的位置信息以提供本地化服务';
  String get trackActivity => '活动跟踪';
  String get trackActivityDesc => '记录您的应用使用情况以提供个性化推荐';
  String get trackBrowsingHistory => '浏览历史';
  String get trackBrowsingHistoryDesc => '保存您的浏览历史以提供更好的内容推荐';
  String get shareAnalytics => '分析数据共享';
  String get shareAnalyticsDesc => '与我们分享匿名使用数据以帮助改进服务';
  String get trackingPrivacyTip =>
      '我们重视您的隐私。您可以随时调整这些设置来控制数据的收集和使用方式。所有数据都将按照我们的隐私政策进行处理。';

  String get communityData => '社区数据';
  String get ourModerators => '我们的版主';
  String get ourAdmin => '我们的管理员';
  String get websiteActivity => '网站活跃度';
  String get userActivity => '用户活跃';
  String get contentCreation => '内容创作';
  String get interactionData => '互动数据';
  String get chatData => '聊天数据';
  String get contactUs => '联系我们';
  String get emergencyIssues => '紧急事项';
  String get contactForCriticalIssues => '如果出现影响此网站的关键问题或紧急事项，请联系';
  String get inappropriateContentReport => '不当内容报告';
  String get reportInappropriateContent =>
      '如果您发现任何不当内容，请立即与我们的版主和管理员进行对话。请记住，联系前请先登录。';
  String get versionInfo => '版本信息';
  String get webVersion => 'Web版本号';
  String get appVersion => 'App版本号';
}

class _Posts {
  const _Posts();

  String get disturbSuccess => '设置免打扰成功';
  String get error => '设置失败,请重试~';
  String get reply => '回复';
  String get replyPlaceholder => "提问、回复请记得：真诚、友善、团结、专业，共建你我引以为荣之社区。";
  String get send => '发送';
  String get replySuccess => '回复成功';
  String get replyFailed => '回复失败';
  String get searchTopic => '搜索话题';
  String get copySuccess => '复制成功';
  String get deleteSuccess => '删除成功';
  String get deleteFailed => '删除失败';
  String get deletePost => '帖子已被作者删除';
  String get openBrowser => '选择浏览器';
  String get openInApp => '应用内打开';
  String get openInBrowser => '系统浏览器打开';
  String get views => '浏览量';
  String get likeCount => '点赞数';
  // 举报相关
  List<Map<String, String>> get reasons => [
        {
          'title': '偏离话题',
          'desc': '此帖子与标题和第一个帖子定义的当前讨论无关，可能应该移到其他地方。',
          'value': 'off_topic'
        },
        {
          'title': '不当言论',
          'desc': '这个帖子包含的内容会被一个有理性的人认为具有冒犯性、侮辱性、属于仇恨行为或违反我们的社区准则。',
          'value': 'off_topic'
        },
        {
          'title': '垃圾信息',
          'desc': '此帖子是广告或者蓄意破坏讨论。帖子没有价值或者与当前话题无关。',
          'value': 'inappropriate'
        },
        {
          'title': '违规推广',
          'desc': '我确认：此帖子系用户未遵守社区推广规则，进行违规推广。',
          'value': 'spam'
        },
        {
          'title': '非法',
          'desc': '此帖子需要工作人员注意，因为我认为其中包含非法内容。',
          'value': 'notify_moderators'
        },
        {
          'title': '其他内容',
          'desc': '由于上面未列出的另一个原因，此帖子需要管理人员注意。',
          'value': 'notify_moderators'
        },
      ];

  String get reportTitle => '举报内容';
  String get reportButton => '举报帖子';
  String get reportSuccess => '举报开发中';
  String get reportFailed => '举报失败';

  get reportHint => '让我们具体了解您关心的问题，并尽可能提供相关的链接和示例。';

  String get sendSuccess => '发送成功';
  String get sendFailed => '发送失败';

  String get officialWarning => '官方警告信息';

  String get messagePlaceholder => '在此处输入私信内容...';
  String get titlePlaceholder => '输入标题...';
}

/// 发帖相关常量
class _CreatePost {
  const _CreatePost();

  String get title => '发布新主题';
  String get preview => '预览';
  String get previewTitle => '预览主题';
  String get previewEmpty => '暂无预览内容';
  String get previewCategory => '分类';
  String get previewTags => '标签';
  String get dialogTitle => '创建新的话题';
  String get dialogContent => '为了更好的体验创建话题的功能，\n建议前往 Web 网站完成发布操作。';
  String get dialogConfirm => '去创建';
  String get dialogCancel => '取消';
  String get categoryHint => '选择分类';
  String get titleHint => '请输入标题';
  String get addImage => '添加图片';
  String get searchTag => '搜索标签';
  String get publish => '发布';
  String get draft => '保存草稿';
  String get titleRequired => '请输入标题';
  String get contentRequired => '请输入内容';
  String get categoryRequired => '请选择分类';
  String get publishSuccess => '发布成功';
  String get draftSuccess => '草稿保存成功';
  String get publishFailed => '发布失败';
  String get draftFailed => '草稿保存失败';
  String get selectCategory => '请选择分类';
  String get addTags => '添加标签';
  String get inputTips => '请输入内容';
  String get uploadFailed => '图片上传失败';
  String get previewPost => '请完善内容后预览';
}

class _Chat {
  const _Chat();

  String get title => '私信';
  String get searchHint => '搜索';
  String get noMessages => '暂无消息';
  String get inputHint => '请输入消息';
}

class _CategoryTopics {
  const _CategoryTopics();

  String get groups => '群组';
  String get ranking => '排行榜';
  String get docs => '文档';
  String get activities => '社区活动';
  String get birthdays => '生日';
  String get myPosts => '我的帖子';
  String get myBookmarks => '我的书签';
  String get loading => '加载中...';
  String get noData => '暂无数据';
}

class _Birthday {
  const _Birthday();

  String get title => '生日';
  String get today => '今天';
  String get tomorrow => '明天';
  String get upcoming => '即将到来';
  String get all => '所有';
  String get noBirthdays => '暂无生日信息';
  String get loading => '加载中...';
  String get error => '获取生日数据失败';
  String get birthdayOn => '生日';
}

class _Activity {
  const _Activity();

  String get title => '社区活动';
  String get noEvents => '暂无活动';
  String get loading => '加载中...';
  String get error => '获取活动数据失败';
  String get startTime => '开始时间';
  String get endTime => '结束时间';
  String get viewDetail => '查看详情';
  String get today => '今天';
}

class _Leaderboard {
  const _Leaderboard();
  final String title = '排行榜';
  final String firstPlace = '第一名';
  final String secondPlace = '第二名';
  final String thirdPlace = '第三名';
  final String points = '积分';
  final String error = '获取排行榜数据失败';
  final String empty = '暂无排行榜数据';

  String get tips =>
      '参与社区活动，如访问、点赞和发帖，都会获得积分。您的积分每几分钟就会更新一次。保持活跃，积极帮助并支持其他人来提高自己的排名！';
  String get tipsTitle => '排行榜说明';
  String get tipsKnow => '知道了';
}

class _Group {
  const _Group();

  String get title => '群组';
  String get members => '成员';
  String get join => '加入';
  String get leave => '退出';
  String get joinSuccess => '加入成功';
  String get leaveSuccess => '退出成功';
  String get joinFailed => '加入失败';
  String get leaveFailed => '退出失败';
  String get noDescription => '暂无描述';
  String get publicGroup => '公开群组';
  String get privateGroup => '私密群组';
  String get loading => '加载中...';
  String get error => '获取群组数据失败';
  String get empty => '暂无群组数据';
  String get search => '搜索群组';
}

class _User {
  const _User();

  String get noDescription => '暂无简介';
  String get admin => '管理员';
  String get joinTime => '加入时间';
  String get postTime => '发布时间';
  String get points => '点数';
  String get follow => '关注';
  String get followers => '关注者';
  String get solutions => '解决方案';
  String get like => '认可';
  String get followUser => '关注';
  String get unfollowUser => '取消关注';
  String get message => '私信';
  String get chat => '聊天';
  String get failed => '失败，请稍后重试~';

  // 用户优点选项
  String get readingPoetry => '读书成诗';
  String get sevenThree => '掐七捏三';
  String get marketInsight => '跳蚤市场';
  String get communityBuilding => '文档共建';
  String get welfareSheep => '福利羊毛';
  String get devOps => '开发调优';
  String get frontierNews => '前沿快讯';
  String get startupNavigation => '扬帆起航';
  String get resourceSharing => '资源荟萃';
  String get nonMainstream => '非我莫属';
}
