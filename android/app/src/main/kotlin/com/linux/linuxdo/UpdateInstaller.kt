package com.linux.linuxdo

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest
import java.util.zip.ZipFile

/** No silent install: validate the private APK, then ask Android's installer. */
object UpdateInstaller {
    @Suppress("DEPRECATION")
    fun attach(activity: Activity, messenger: BinaryMessenger) {
        MethodChannel(messenger, "com.linux.linuxdo/updater").setMethodCallHandler { call, result ->
            if (call.method != "install") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            try {
                val path = call.argument<String>("path") ?: error("APK_PATH")
                val file = File(path).canonicalFile
                val root = File(activity.cacheDir, "linuxdo-updates").canonicalFile
                check(file.parentFile == root && file.extension == "apk" && file.isFile) { "APK_PATH" }
                val pm = activity.packageManager
                val flags = if (Build.VERSION.SDK_INT >= 28) PackageManager.GET_SIGNING_CERTIFICATES else PackageManager.GET_SIGNATURES
                val archive = pm.getPackageArchiveInfo(file.path, flags) ?: error("APK_INVALID")
                val installed = pm.getPackageInfo(activity.packageName, flags)
                check(archive.packageName == activity.packageName) { "PACKAGE_MISMATCH" }
                val newCode = if (Build.VERSION.SDK_INT >= 28) archive.longVersionCode else archive.versionCode.toLong()
                val oldCode = if (Build.VERSION.SDK_INT >= 28) installed.longVersionCode else installed.versionCode.toLong()
                check(newCode > oldCode) { "VERSION_DOWNGRADE" }
                val currentSigners = signers(installed)
                check(currentSigners.isNotEmpty() && currentSigners == signers(archive)) { "SIGNATURE_MISMATCH" }
                check((archive.applicationInfo?.minSdkVersion ?: Int.MAX_VALUE) <= Build.VERSION.SDK_INT) { "ANDROID_VERSION" }
                ZipFile(file).use { zip ->
                    check(Build.SUPPORTED_ABIS.any { abi -> zip.getEntry("lib/$abi/libapp.so") != null }) { "ABI_MISMATCH" }
                }
                if (Build.VERSION.SDK_INT >= 26 && !pm.canRequestPackageInstalls()) {
                    activity.startActivity(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                        Uri.parse("package:${activity.packageName}")))
                    result.error("INSTALL_PERMISSION", "Allow installation in system settings, then retry.", null)
                    return@setMethodCallHandler
                }
                val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.updates", file)
                activity.startActivity(Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(uri, "application/vnd.android.package-archive")
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                })
                result.success(null)
            } catch (e: Exception) {
                val code = e.message?.takeIf { it.matches(Regex("[A-Z_]+")) } ?: "INSTALL_FAILED"
                result.error(code, "Android rejected the update. Existing application data is unchanged.", null)
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun signers(info: PackageInfo): Set<String> {
        val signatures = if (Build.VERSION.SDK_INT >= 28) info.signingInfo?.apkContentsSigners else info.signatures
        return signatures.orEmpty().map { signature ->
            MessageDigest.getInstance("SHA-256").digest(signature.toByteArray())
                .joinToString("") { "%02x".format(it) }
        }.toSet()
    }
}
