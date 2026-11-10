# LINUX DO 🐧

<p align="center">
  <picture>
    <source 
      srcset="assets/images/dark/logo.webp" 
      media="(prefers-color-scheme: dark)"
    />
    <img 
      src="assets/images/light/logo.webp" 
      width="200" 
      alt="LINUX DO Logo"
    />
  </picture>
</p>

---

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.27.2-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6.1-red.svg)](https://dart.dev)
[![App Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/R-lz/LINUX-DO/main/pubspec.yaml&query=$.version&label=Version&color=orange)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![EN](https://img.shields.io/badge/English-README-blue.svg)](README.en.md)

</div>


## 🌟 这是什么？

使用Flutter开发的LINUX DO客户端,支持 `Android` `IOS`.


## 📦 项目结构

```
lib/
├── 🏛 const/          
├── 🧠 controller/      
├── 🗃 models/         
├── 🌐 net/          
├── 📱 pages/        
├── 🗺 routes/       
├── ⚙️ utils/         
└── 🎨 widgets/       
```

## 🚀 启程指南

### 环境准备

```yaml
必要条件:
  - Flutter: ">=3.0.0 <4.0.0"
  - Dart: ">=3.0.0 <4.0.0"
  - 开发工具: Android Studio / VS Code
  - iOS: Xcode 13.0+（用于iOS开发）
  - Android: Android SDK（用于Android开发）
```

    安装flutter
```bash
# 检查安装结果
flutter --version

# 检查环境
flutter doctor -v
```

### 🎯 开发环境配置

#### 1. 项目获取
```bash
# 克隆项目
git clone https://github.com/R-lz/LINUX-DO.git
cd LINUX-DO

# 安装依赖
flutter pub get
```

#### 2. 代码生成
```bash
# 生成路由、JSON序列化等代码
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 3. 平台特定配置

<details>
<summary>iOS 配置</summary>
</br>

    确保系统中安装了xcode,cocoapods

```bash
# 进入 iOS 目录
cd ios

pod cache clean --all
rm -rf Pods Podfile.lock

pod install --repo-update

cd ..
```
</details>

---


<details>
<summary>Android 配置</summary>
</br>

    确保你的系统中已安装JDK，并配置了环境变量（JAVA_HOME 和 PATH）

#### 生成签名文件
```bash
mkdir -p keystore
```

```bash
keytool -genkey -v -keystore keystore/linux-do.jks -alias mykey -keyalg RSA -keysize 2048 -validity 10000
```

继续交互式
``` bash
Enter keystore password:  [输入 Keystore 密码]
Re-enter new password:   [再次输入确认密码]
What is your first and last name? 
... ...
```
创建key.properties
```bash
touch keystore/key.properties

cat > keystore/key.properties << EOF
storePassword=<你的Keystore密码>
keyPassword=<你的密钥密码>
keyAlias=mykey
storeFile=../keystore/linux-do.jks
EOF
```

</details>


### 🚀 启动项目

#### iOS
```bash
# 开发版本
flutter run -d ios

# 发布版本
flutter build ios --release
```

#### Android
```bash
# 开发版本
flutter run -d android

# 安卓打包
flutter build apk --release --split-per-abi
```


<details>
<summary>使用Github Actions编译打包</summary>

#### Android:
    配置 KEYSTORE_BASE64 | KEY_PROPERTIES

```bash
# 生成base64
base64 -i release.jks
```
配置步骤:
- 打开仓库Settings
- 点击 `Secrets and variables` -> `New repository secret`
- 添加两个Secret
- 添加 Key: `KEYSTORE_BASE64` Value:<生成的base64>
- 添加KEY_PROPERTIES 复制整个`key.properties`文本内容
- 转到Actions运行`build_android`


#### IOS:
    ios为未签名的IPA,直接运行`build_ios`
    
</details>


---


## 🤝 参与贡献

每一个想法都值得被倾听，每一行代码都应该被尊重。

- 发现任何问题或功能上的建议,请通过Issues反馈
- 欢迎提交PR
- 感谢你对项目的贡献！


如果这个项目有帮助到你，请献上你的 Star ⭐️
你的认可，是我们前进的动力。

## 🛠 本地开发

### 环境要求

| 组件 | 版本 |
|---|---|
| Flutter | 3.35.7（stable） |
| Dart | 3.9+ |
| JDK | 17 |
| Android compileSdk | 36 |
| Android targetSdk | 35 |

CI 固定同一套版本（`.github/workflows/ci.yml`），本地请保持一致，避免依赖解析差异。
`pubspec.lock` 已入库，修改依赖后请一并提交锁文件。

### 签名配置

签名口令**不入库**。release 构建前创建 `android/keystore/key.properties`：

```properties
storePassword=<你的口令>
keyPassword=<你的口令>
storeFile=app/release-key.jks
keyAlias=linuxdo
```

该文件与 `*.jks` 均被 `.gitignore` 排除。缺少此文件时 release 构建会跳过签名并打印警告。

### 16KB 页对齐校验

Android 15 起的新硬件使用 16KB 内存页。若 APK 内 native 库的 ELF `LOAD` 段未按 16KB
对齐（`p_align < 0x4000`），应用会启动即崩溃；Google Play 也已要求新提交支持 16KB。

构建后执行：

```bash
bash scripts/check_16k_alignment.sh build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

脚本逐个检查 `.so` 并输出 `OK` / `FAIL`。CI 的 `build-android` job 会自动运行，存在未对齐
库时构建失败。常见来源是 MLKit（`mobile_scanner`）、CameraX 与 `jni`；遇到 `FAIL` 优先升级
对应插件。

### 代码规范

```bash
dart format lib test          # 格式化
flutter analyze --no-pub      # 静态分析（CI 要求 0 warning / 0 error）
flutter test --no-pub         # 单元测试
```

## 📜 开源协议

本项目采用MIT许可证 - 请参阅[LICENSE](LICENSE)文件以获取详细信息。
