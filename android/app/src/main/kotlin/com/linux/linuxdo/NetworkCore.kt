package com.linux.linuxdo

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File
import java.net.HttpURLConnection
import java.net.InetAddress
import java.net.ServerSocket
import java.net.URL
import java.security.SecureRandom
import java.util.concurrent.Executors
import android.os.Handler
import android.os.Looper

/** App-only proxy: no VPN, system proxy, external commands or downloaded executable code. */
object NetworkCore {
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var process: Process? = null
    private var endpoint: Map<String, Any>? = null
    private var phase = "idle"

    fun attach(context: Context, messenger: BinaryMessenger) {
        val app = context.applicationContext
        MethodChannel(messenger, "com.linux.linuxdo/network_core").setMethodCallHandler { call, result ->
            worker.execute {
                try {
                    val response: Any? = when (call.method) {
                        "start" -> start(app, call.argument<String>("config") ?: "")
                        "stop" -> { stop(app); null }
                        "status" -> endpoint?.plus("running" to isAlive(process))
                        else -> { main.post { result.notImplemented() }; return@execute }
                    }
                    main.post { result.success(response) }
                } catch (error: Exception) {
                    android.util.Log.w("LinuxDoProxy", "Core operation failed: $phase (${error.javaClass.simpleName})")
                    // Never expose configuration, subscription credentials or core output to logs.
                    val detail = mapOf("stage" to phase, "type" to error.javaClass.simpleName,
                        "diagnostic" to ((error as? CoreLaunchException)?.diagnostic ?: ""))
                    main.post { result.error("PROXY_CORE", "代理核心启动失败，请检查订阅节点配置", detail) }
                }
            }
        }
    }

    private fun freePort(): Int = ServerSocket(0, 1, InetAddress.getByName("127.0.0.1")).use { it.localPort }

    private fun start(context: Context, text: String): Map<String, Any> {
        phase = "validating-input"
        require(text.length in 1..2 * 1024 * 1024)
        val config = JSONObject(text)
        val binary = File(context.applicationInfo.nativeLibraryDir, "liblinuxdo_proxy.so")
        phase = "checking-binary"
        check(binary.isFile && binary.canExecute())
        val directory = File(context.filesDir, "network-core").canonicalFile.apply { mkdirs() }
        val port = freePort()
        var controller = freePort()
        while (controller == port) controller = freePort()
        val token = ByteArray(32).also { SecureRandom().nextBytes(it) }.joinToString("") { "%02x".format(it) }
        config.put("mixed-port", port)
        config.put("external-controller", "127.0.0.1:$controller")
        config.put("secret", token)
        config.put("bind-address", "127.0.0.1")
        config.put("allow-lan", false)
        val file = File(directory, "pending.json")
        val encoded = config.toString()
        val yamlJson = jsonForYaml(encoded)
        check(JSONObject(yamlJson).toString() == encoded)
        file.writeText(yamlJson)
        file.setReadable(false, false); file.setReadable(true, true)
        file.setWritable(false, false); file.setWritable(true, true)
        // Validate before stopping a working configuration.
        phase = "validating-config"
        val validation = coreBuilder(context, directory, binary.path, "-t", "-d", directory.path, "-f", file.path).start()
        val output = java.io.ByteArrayOutputStream()
        val reader = Thread {
            validation.inputStream.use { input ->
                val bytes = ByteArray(1024)
                try {
                    while (true) {
                        val count = input.read(bytes)
                        if (count < 0) break
                        synchronized(output) {
                            if (output.size() < 8192) output.write(bytes, 0, minOf(count, 8192 - output.size()))
                        }
                    }
                } catch (_: Exception) { }
            }
        }.apply { isDaemon = true; start() }
        if (!waitForExit(validation, 12000)) {
            validation.destroy(); file.delete(); error("Validation timeout")
        }
        if (validation.exitValue() != 0) {
            reader.join(200)
            phase = "validation-exit-${validation.exitValue()}"
            val diagnostic = synchronized(output) { redact(output.toString("UTF-8"), config) }
            file.delete(); throw CoreLaunchException(diagnostic)
        }
        process?.destroy()
        process?.let { check(waitForExit(it, 2000)) }
        val active = File(directory, "config.json")
        check(file.renameTo(active))
        val child = coreBuilder(context, directory, binary.path, "-d", directory.path, "-f", active.path).start()
        process = child
        phase = "waiting-ready"
        discardOutput(child)
        repeat(60) {
            if (!isAlive(child)) { endpoint = null; error("Core exited") }
            try {
                val connection = URL("http://127.0.0.1:$controller/version").openConnection() as HttpURLConnection
                connection.connectTimeout = 200; connection.readTimeout = 200
                connection.setRequestProperty("Authorization", "Bearer $token")
                val ready = connection.responseCode == 200
                connection.disconnect()
                if (ready) {
                    phase = "ready"
                    return mapOf("port" to port, "controllerPort" to controller, "secret" to token)
                        .also { endpoint = it }
                }
            } catch (_: Exception) { }
            Thread.sleep(50)
        }
        stop(context)
        error("Core did not become ready")
    }

    private fun discardOutput(child: Process) {
        Thread({ child.inputStream.use { input ->
            val bytes = ByteArray(4096)
            try { while (input.read(bytes) != -1) { } } catch (_: Exception) { }
        } }, "linuxdo-proxy-output").apply { isDaemon = true; start() }
    }

    private fun stop(context: Context) {
        process?.destroy()
        process?.let { waitForExit(it, 2000) }
        process = null; endpoint = null
        File(context.filesDir, "network-core/config.json").delete()
        File(context.filesDir, "network-core/pending.json").delete()
    }

    private fun isAlive(child: Process?): Boolean {
        if (child == null) return false
        return try { child.exitValue(); false } catch (_: IllegalThreadStateException) { true }
    }

    private class CoreLaunchException(val diagnostic: String) : Exception()

    private fun coreBuilder(context: Context, directory: File, vararg command: String): ProcessBuilder {
        return ProcessBuilder(*command).directory(directory).redirectErrorStream(true).apply {
            environment()["HOME"] = directory.path
            environment()["TMPDIR"] = context.cacheDir.canonicalPath
            environment()["SAFE_PATHS"] = directory.path
        }
    }

    private fun redact(raw: String, config: JSONObject): String {
        val values = mutableSetOf<String>()
        fun collect(value: Any?, key: String = "") {
            when (value) {
                is JSONObject -> value.keys().forEach { collect(value.opt(it), it) }
                is org.json.JSONArray -> (0 until value.length()).forEach { collect(value.opt(it), key) }
                else -> if (value != null && value != JSONObject.NULL) {
                    val text = value.toString()
                    if ((value is String && text.length >= 4) ||
                        listOf("password", "uuid", "auth", "key", "token").any { key.contains(it, true) }) values.add(text)
                }
            }
        }
        collect(config)
        var safe = raw
        values.sortedByDescending { it.length }.forEach { safe = safe.replace(it, "<redacted>") }
        return safe.replace(Regex("https?://[^\\s]+"), "<url>").take(1000)
    }

    private fun waitForExit(child: Process, timeoutMillis: Long): Boolean {
        val end = android.os.SystemClock.elapsedRealtime() + timeoutMillis
        while (isAlive(child) && android.os.SystemClock.elapsedRealtime() < end) Thread.sleep(25)
        return !isAlive(child)
    }
}
