import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/models/follow.dart';
import 'package:linux_do/models/user_post.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/utils/mixins/concatenated.dart';
import 'package:linux_do/utils/tag.dart';
import '../../controller/base_controller.dart';

class FollowController extends BaseController with Concatenated {
  final ApiService _apiService = Get.find();

  // 标签索引 (0: 动态, 1: 关注, 2: 关注者)
  final RxInt selectedIndex = 0.obs;

  // 用于控制标签页之间的切换
  late final PageController pageController;

  final RxList<Follow> following = <Follow>[].obs;
  final RxList<Follow> followers = <Follow>[].obs;
  final RxList<UserPost> userPosts = <UserPost>[].obs;

  // 用户帖子分页状态
  final RxBool hasMorePosts = false.obs;
  String? lastPostTimestamp;

  // 关注列表分页状态
  final RxBool hasMoreFollowing = false.obs;
  final RxInt followingOffset = 0.obs;
  final RxBool followingLoaded = false.obs;
  final RxBool followingLoading = false.obs;

  // 关注者列表分页状态
  final RxBool hasMoreFollowers = false.obs;
  final RxInt followersOffset = 0.obs;
  final RxBool followersLoaded = false.obs;
  final RxBool followersLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    CategoryManager().initialize();

    // 初始化PageController
    pageController = PageController(initialPage: selectedIndex.value);

    getUserPosts();

    // 监听标签页切换，实现延迟加载
    ever(selectedIndex, (index) {
      if (index == 1 && !followingLoaded.value) {
        getFollowing();
      } else if (index == 2 && !followersLoaded.value) {
        getFollowers();
      }
    });
  }

  // 切换标签
  void switchTab(int index) {
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 根据页面滑动更新选中的标签
  void onPageChanged(int page) {
    if (selectedIndex.value != page) {
      selectedIndex.value = page;
    }
  }

  // 获取用户帖子
  Future<void> getUserPosts({bool loadMore = false}) async {
    try {
      isLoading.value = true;

      // 如果是加载更多，使用最后一条帖子的时间戳
      final response = await _apiService.getUserPosts(
        userName,
        createdBefore: loadMore ? lastPostTimestamp : null,
      );

      if (loadMore) {
        userPosts.addAll(response.posts);
      } else {
        userPosts.value = response.posts;
      }

      hasMorePosts.value = response.extras.hasMore;

      if (response.posts.isNotEmpty) {
        lastPostTimestamp = response.posts.last.createdAt;
      }
    } catch (e, s) {
      showError('获取帖子失败：$e ---$s');
    } finally {
      isLoading.value = false;
    }
  }

  // 加载更多帖子
  Future<void> loadMorePosts() async {
    if (hasMorePosts.value && !isLoading.value) {
      await getUserPosts(loadMore: true);
    }
  }

  // 刷新用户帖子
  Future<void> refreshPosts() async {
    lastPostTimestamp = null;
    await getUserPosts();
  }

  // 获取关注者列表
  Future<void> getFollowers({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        followersLoading.value = true;
      }

      // 计算分页偏移量
      final offset = loadMore ? followersOffset.value : 0;

      final response = await _apiService.getFollowers(userName);

      if (loadMore) {
        followers.addAll(response);
      } else {
        followers.value = response;
      }

      // 假设如果返回的数据少于20条，说明没有更多数据了
      // 改接口好像没有分页 但保留分页逻辑
      hasMoreFollowers.value = response.length >= 20;

      if (response.isNotEmpty) {
        followersOffset.value = offset + response.length;
      }

      followersLoaded.value = true;
    } catch (e, s) {
      l.e('获取关注者失败 $e --- $s');
      showError('获取关注者失败：$e');
    } finally {
      followersLoading.value = false;
    }
  }

  // 加载更多关注者
  Future<void> loadMoreFollowers() async {
    if (hasMoreFollowers.value && !followersLoading.value) {
      followersLoading.value = true;
      await getFollowers(loadMore: true);
      followersLoading.value = false;
    }
  }

  // 刷新关注者列表
  Future<void> refreshFollowers() async {
    followersOffset.value = 0;
    await getFollowers();
  }

  // 获取关注列表
  Future<void> getFollowing({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        followingLoading.value = true;
      }

      // 计算分页偏移量
      final offset = loadMore ? followingOffset.value : 0;

      final response = await _apiService.getFollowing(userName);
      l.i('获取关注 ${jsonEncode(response)}');

      if (loadMore) {
        following.addAll(response);
      } else {
        following.value = response;
      }

      // 判断是否还有更多数据
      hasMoreFollowing.value = response.length >= 20;

      if (response.isNotEmpty) {
        followingOffset.value = offset + response.length;
      }

      followingLoaded.value = true;
    } catch (e, s) {
      l.e('获取关注列表失败 $e --- $s');
      showError('获取关注列表失败：$e');
    } finally {
      followingLoading.value = false;
    }
  }

  // 加载更多关注
  Future<void> loadMoreFollowing() async {
    if (hasMoreFollowing.value && !followingLoading.value) {
      followingLoading.value = true;
      await getFollowing(loadMore: true);
      followingLoading.value = false;
    }
  }

  // 刷新关注列表
  Future<void> refreshFollowing() async {
    followingOffset.value = 0;
    await getFollowing();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void unfollowUser(String username) async {
    // 取消关注
    try {
      await _apiService.unfollowUser(username);
      following.removeWhere((element) => element.username == username);
    } catch (e, s) {
      l.e('取消关注失败 $e --- $s');
    }
  }

  void followUser(String username) async {
    // 关注
    try {
      await _apiService.followUser(username);
      if (!following.any((element) => element.username == username)) {
        following.add(Follow(username: username));
      }
    } catch (e, s) {
      l.e('关注失败 $e --- $s');
    }
  }

  // 跳转到帖子详情
  void toTopicDetail(int id, int postNumber) {
    Get.toNamed(
      Routes.TOPIC_DETAIL,
      arguments: id,
      parameters: {'postNumber': postNumber.toString()},
    );
  }
}
