package com.linux.linuxdo

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * 宿主 Activity。
 *
 * 转发外部分享文本，并注册应用内代理核心的 Flutter 通道。
 * app_links 只处理 VIEW 类型的深链，ACTION_SEND 不在其覆盖范围内，
 * 所以这里用一个极薄的 MethodChannel 承接，避免再引入一个只为传一段文本的
 * 第三方依赖。
 */
class MainActivity : FlutterActivity() {

    private var channel: MethodChannel? = null

    /** Flutter 侧尚未注册 handler 时先暂存，等它主动来取。 */
    private var pendingShare: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NetworkCore.attach(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        ).also { ch ->
            ch.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialShare" -> {
                        // 冷启动：优先取暂存的，其次从当前 intent 里挖
                        val text = pendingShare ?: extractSharedText(intent)
                        pendingShare = null
                        result.success(text)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // singleTop 复用实例时，后续 intent 必须 setIntent 才能被 getIntent 读到
        setIntent(intent)

        val text = extractSharedText(intent) ?: return
        val ch = channel
        if (ch == null) {
            // Flutter engine 还没起来，先存着，等 Dart 调 getInitialShare
            pendingShare = text
        } else {
            ch.invokeMethod("onShare", text)
        }
    }

    // 只接受 ACTION_SEND 且 MIME 以 text/ 开头，其他 intent 一律忽略。
    // 注意：这里不能用块注释，因为 "text" 后面跟斜杠加星号会被 Kotlin
    // 当成嵌套块注释的起始符号。
    private fun extractSharedText(intent: Intent?): String? {
        if (intent == null) return null
        if (intent.action != Intent.ACTION_SEND) return null
        if (intent.type?.startsWith("text/") != true) return null
        val text = intent.getStringExtra(Intent.EXTRA_TEXT) ?: return null
        return text.takeIf { it.isNotBlank() }
    }

    companion object {
        private const val CHANNEL_NAME = "com.linux.linuxdo/share"
    }
}
