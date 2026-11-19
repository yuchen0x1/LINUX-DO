import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../net/update_checker.dart';
import '../net/update_downloader.dart';

class DisAppUpdate {
  static void showUpdateDialog(ReleaseUpdate update) {
    Get.dialog<void>(_UpdateDialog(update: update), barrierDismissible: false);
  }
}

class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog({required this.update});
  final ReleaseUpdate update;
  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  final _downloader = UpdateDownloader();
  CancelToken? _cancel;
  File? _apk;
  double _progress = 0;
  double _speed = 0;
  String? _error;
  bool _busy = false;
  @override
  void dispose() {
    _cancel?.cancel();
    _downloader.close();
    super.dispose();
  }

  Future<void> _install() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final started = DateTime.now();
    try {
      _cancel = CancelToken();
      _apk ??= await _downloader.download(
        widget.update,
        cancelToken: _cancel!,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _progress = received / total;
            _speed =
                received /
                (DateTime.now().difference(started).inMilliseconds + 1) *
                1000 /
                1024;
          });
        },
      );
      await UpdateDownloader.install(_apk!);
      if (mounted) Navigator.of(context).pop();
    } on PlatformException catch (e) {
      if (mounted)
        setState(() {
          _error = e.code == 'INSTALL_PERMISSION'
              ? '请在系统设置中允许安装，返回后再次点击安装。'
              : '系统未能安装更新（${e.code}），请查看发行说明或重试。';
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e is DioException && CancelToken.isCancel(e)
              ? '下载已取消，可重新下载。'
              : '下载或校验失败，请检查网络与存储空间后重试。';
        });
    } finally {
      if (mounted)
        setState(() {
          _busy = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final update = widget.update;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: const Text('LINUX DO 更新'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${update.currentVersion} → ${update.latestVersion}'),
                const SizedBox(height: 8),
                Text(
                  '${(update.size / 1024 / 1024).toStringAsFixed(1)} MB'
                  '${update.publishedAt == null ? '' : ' · ${update.publishedAt!.toLocal().toString().split(' ').first}'}',
                ),
                const SizedBox(height: 16),
                Text(update.releaseNotes ?? '查看发行说明了解本次更新。'),
                if (_busy) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: _progress),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}% · ${_speed.toStringAsFixed(0)} KB/s',
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy
                ? null
                : () => launchUrl(
                    Uri.parse(update.releaseUrl),
                    mode: LaunchMode.externalApplication,
                  ),
            child: const Text('发行说明'),
          ),
          TextButton(
            onPressed: _busy
                ? () => _cancel?.cancel()
                : () async {
                    await UpdatePreferences.defer(update.latestVersion!);
                    if (context.mounted) Navigator.of(context).pop();
                  },
            child: Text(_busy ? '取消下载' : '七天后提醒'),
          ),
          FilledButton(
            onPressed: _busy ? null : _install,
            child: Text(_apk == null ? '下载并安装' : '安装更新'),
          ),
        ],
      ),
    );
  }
}
