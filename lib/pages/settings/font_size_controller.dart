import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/models/topic_model.dart';
import 'package:linux_do/utils/storage_manager.dart';
import 'package:linux_do/utils/user_cache.dart';

enum ListDensity { compact, normal, loose }

class FontSizeController extends BaseController {
  // 帖子内容字体大小
  final Rx<double> postFontSize = 14.0.obs;
  // 回复内容字体大小
  final Rx<double> replyFontSize = 11.0.obs;

  // 字体大小范围 字体太多不太好看的样子
  final double minFontSize = 10.0;
  final double maxFontSize = 20.0;

  // 布局密度设置
  final Rx<ListDensity> listDensity = ListDensity.normal.obs;

  // 示例文本
  final String exampleText =
      '字体大小示例文本 - Sincere, friendly, united, and professional, let`s jointly build a community that we are proud of.';
  final String exampleMarkdown = '''
<p>我们非常高兴看到您加入我们。</p>
<blockquote>
<h2>LINUX DO</h2>
<p>Where possible begins.</p>
</blockquote>
<p>以下是一些可以帮助您入门的事情：</p>
<p><img src="https://linux.do/images/emoji/twemoji/speaking_head.png?v=12" title=":speaking_head:" class="emoji" alt=":speaking_head:" loading="lazy" width="20" height="20"> 在<a href="/my/preferences/profile">个人资料</a>中添加您的照片和关于您自己和您的兴趣的信息，<strong>介绍您自己</strong>。您希望被别人了解的一件事是什么？</p>
<p><img src="https://linux.do/images/emoji/twemoji/open_book.png?v=12" title=":open_book:" class="emoji" alt=":open_book:" loading="lazy" width="20" height="20"> 通过<a href="/top">浏览这些已经发生的讨论</a>来<strong>了解社区</strong>。当您发现一个帖子很有趣、信息量很大或者很有娱乐性时，请使用 <img src="https://linux.do/images/emoji/twemoji/heart.png?v=12" title=":heart:" class="emoji" alt=":heart:" loading="lazy" width="20" height="20"> 表达您的欣赏或支持！</p>
<p><img src="https://linux.do/images/emoji/twemoji/handshake.png?v=12" title=":handshake:" class="emoji" alt=":handshake:" loading="lazy" width="20" height="20"> 通过评论、分享您自己的观点、提出问题或在讨论中提供反馈来<strong>贡献</strong>。在回复或开始新话题之前，请查阅<a href="/faq">社区准则</a>。</p>
<blockquote>
<p>如果您需要帮助或有建议，请随时在 <a class="hashtag-cooked" href="/c/feedback/2" data-type="category" data-slug="feedback" data-id="2"><span class="hashtag-icon-placeholder"><svg class="fa d-icon d-icon-square-full svg-icon svg-node"><use href="#square-full"></use></svg></span><span>运营反馈</span></a> 中提问或<a href="/about">联系管理员</a>。</p>
</blockquote>

''';
  final String exampleCode =
      '''<pre data-code-wrap="dart"><code class="lang-dart">
void main() {
  print('Hello, ${AppConst.siteName}!');
}
</code></pre>''';

  final String replyExampleText = '''
字体大小示例文本 - Sincere, friendly, united, and professional, let`s jointly build a community that we are proud of.
''';

  final String replyExampleMarkdown = '''
<p><strong>Neo</strong> Pitt</p>
<p><img src="https://linux.do/images/emoji/twemoji/yum.png?v=12" title=":yum:" class="emoji" alt=":yum:" loading="lazy" width="20" height="20"> <img src="https://linux.do/images/emoji/twemoji/yum.png?v=12" title=":yum:" class="emoji" alt=":yum:" loading="lazy" width="20" height="20"> <img src="https://linux.do/images/emoji/twemoji/yum.png?v=12" title=":yum:" class="emoji" alt=":yum:" loading="lazy" width="20" height="20"> 666666</p>

</br>
<p><strong>Linux</strong> root</p>
<p>来了 <img src="https://linux.do/images/emoji/twemoji/kissing_heart.png?v=12" title=":kissing_heart:" class="emoji" alt=":kissing_heart:" loading="lazy" width="20" height="20"> <img src="https://linux.do/images/emoji/twemoji/kissing_heart.png?v=12" title=":kissing_heart:" class="emoji" alt=":kissing_heart:" loading="lazy" width="20" height="20"> <img src="https://linux.do/images/emoji/twemoji/kissing_heart.png?v=12" title=":kissing_heart:" class="emoji" alt=":kissing_heart:" loading="lazy" width="20" height="20"> <img src="https://linux.do/images/emoji/twemoji/kissing_heart.png?v=12" title=":kissing_heart:" class="emoji" alt=":kissing_heart:" loading="lazy" width="20" height="20"></p>

''';

  final _userCache = UserCache();

  final Rx<bool> simplified = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFontSizeSettings();
    _loadListDensitySettings();
  }

  /// 加载字体大小设置
  void _loadFontSizeSettings() {
    // 从存储中读取设置
    final savedPostFontSize = StorageManager.getDouble(
      AppConst.identifier.postFontSize,
    );
    final savedReplyFontSize = StorageManager.getDouble(
      AppConst.identifier.replyFontSize,
    );
    final savedSimplified = StorageManager.getBool(
      AppConst.identifier.simplified,
    );

    if (savedPostFontSize != null) {
      postFontSize.value = savedPostFontSize;
    }

    if (savedReplyFontSize != null) {
      replyFontSize.value = savedReplyFontSize;
    }

    if (savedSimplified != null) {
      simplified.value = savedSimplified;
    }
  }

  /// 加载布局密度设置
  void _loadListDensitySettings() {
    // 从存储中读取设置
    final savedDensity = StorageManager.getInt(AppConst.identifier.listDensity);
    if (savedDensity != null && savedDensity < ListDensity.values.length) {
      listDensity.value = ListDensity.values[savedDensity];
    }
  }

  void setPostFontSize(double size) {
    postFontSize.value = size;
    StorageManager.setData(AppConst.identifier.postFontSize, size);
  }

  void setReplyFontSize(double size) {
    replyFontSize.value = size;
    StorageManager.setData(AppConst.identifier.replyFontSize, size);
  }

  void setListDensity(ListDensity density) {
    listDensity.value = density;
    StorageManager.setData(AppConst.identifier.listDensity, density.index);
  }

  /// 重置字体大小为默认值
  void resetToDefaults() {
    setPostFontSize(14.0);
    setReplyFontSize(11.0);
    setListDensity(ListDensity.normal);
    showSuccess('已重置为默认设置');
  }

  /// 保存设置并返回
  void saveAndExit() {
    showSuccess('设置已保存');
    Get.back();
  }

  // 获取最新发帖人头像
  String? getLatestPosterAvatar(Topic topic) {
    final latestPosterId = topic.getOriginalPosterId();
    if (latestPosterId == null) return null;
    return _userCache.getAvatarUrl(latestPosterId);
  }

  // 获取昵称
  String? getNickName(Topic topic) {
    final latestPosterId = topic.getOriginalPosterId();
    if (latestPosterId == null) return null;
    return _userCache.getNickName(latestPosterId);
  }

  // 获取用户名
  String? getUserName(Topic topic) {
    final id = topic.getOriginalPosterId();
    if (id == null) return null;
    return _userCache.getUserName(id);
  }

  List<String> getAvatarUrls(Topic topic) {
    // 通过_userCache获取头像
    final avatarUrls = topic.getAvatarUrls();
    return avatarUrls
        .map((id) => _userCache.getAvatarUrl(id))
        .whereType<String>()
        .toList();
  }

  void setSimplified(bool value) {
    simplified.value = value;
    StorageManager.setData(AppConst.identifier.simplified, value);
  }
}
