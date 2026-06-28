import 'package:flutter/widgets.dart';

/// 简体中文本地化字符串
class IntifaceLocalizations {
  const IntifaceLocalizations._();

  // ---- 通用 ----
  static const String ok = '确定';
  static const String cancel = '取消';
  static const String back = '返回';
  static const String delete = '删除';
  static const String clear = '清除';
  static const String error = '错误';
  static const String update = '更新';
  static const String news = '新闻';
  static const String learnMore = '了解更多';
  static const String appName = 'Intiface Central';

  // ---- 导航 ----
  static const String navNews = '新闻';
  static const String navAppModes = '应用模式';
  static const String navDevices = '设备';
  static const String navLog = '日志';
  static const String navSettings = '设置';
  static const String navHelpAbout = '帮助 / 关于';
  static const String navExit = '退出';
  static const String navSendLogs = '发送日志';

  // ---- 控制面板 (control_widget.dart) ----
  static const String portInUse = '端口被占用';
  static const String openTroubleshooting = '打开故障排除';
  static const String unknownStatus = '状态未知';
  static const String serverRunningNoClient = '服务器运行中，无客户端连接';
  static const String serverStarted = '服务器已启动';
  static const String serverNotRunning = '服务器未运行';
  static const String serverStarting = '服务器启动中...';
  static const String engineFileNotFound = '引擎文件未找到，请运行"检查更新"';
  static const String engineStatusUnknown = '引擎状态未知';
  static const String clientConnected = '已连接';
  static const String engineRunningWaitingClient = '引擎运行中，等待客户端连接';
  static const String engineStarting = '引擎启动中...';
  static const String engineNotRunning = '引擎未运行';
  static const String repeaterRunning = '中继器运行中';
  static const String repeaterNotRunning = '中继器未运行';
  static const String repeaterStarting = '中继器启动中...';
  static const String restApiRunning = 'REST API 服务器运行中';
  static const String restApiNotRunning = 'REST API 服务器未运行';
  static const String restApiStarting = 'REST API 服务器启动中...';
  static const String status = '状态：';
  static const String serverAddress = '服务器地址：';
  static const String startServer = '启动服务器';
  static const String stopServer = '停止服务器';
  static const String bluetoothNotReady = '蓝牙未就绪';
  static const String showWindow = '显示窗口';
  static const String quit = '退出';

  // ---- 设备页面 (device_page.dart) ----
  static const String startScanning = '开始扫描';
  static const String stopScanning = '停止扫描';
  static const String allowModeActive = '允许模式已激活：仅标记为"允许"的设备会连接';
  static const String noDevicesAvailable = '暂无可用设备';
  static const String startEngineToConnect = '启动引擎并连接设备即可开始使用。';
  static const String manageAdvancedDevices = '管理高级设备';

  // ---- 设备详情页面 (device_detail_page.dart) ----
  static const String backToDeviceList = '返回设备列表';
  static const String deviceInfo = '设备信息';
  static const String hardwareName = '硬件名称';
  static const String displayName = '显示名称';
  static const String protocol = '协议';
  static const String address = '地址';
  static const String index = '索引';
  static const String configuration = '配置';
  static const String messageGap = '消息间隔 (毫秒)';
  static const String default_ = '默认';
  static const String connectToThisDevice = '连接此设备';
  static const String onlyConnectToThisDevice = '仅连接此设备';
  static const String onlyConnectDescription = '启用后，仅标记了此选项的设备才会连接';
  static const String displayNameEntry = '输入显示名称';
  static const String leaveEmptyForDefault = '留空则使用默认值';
  static const String deviceControls = '设备控制';
  static const String toggleOscillation = '切换振荡';
  static const String readSensor = '读取传感器';
  static const String featureConfiguration = '功能配置';
  static const String sensorInput = '传感器输入';
  static const String availableWhenConnected = '连接后可用';
  static const String disabled = '已禁用';
  static const String reverse = '反转';
  static const String forgetDevice = '忘记设备';
  static const String forgetDeviceConfirm = '这将删除此设备的所有配置。确定要执行吗？';
  static const String forget = '忘记';

  // ---- 功能名称 ----
  static const String featureVibrate = '振动';
  static const String featureRotate = '旋转';
  static const String featureOscillate = '振荡';
  static const String featureConstrict = '收缩';
  static const String featureTemperature = '温度';
  static const String featureLED = 'LED';
  static const String featureSpray = '喷雾';
  static const String featurePosition = '位置';
  static const String featurePositionWithDuration = '带时长位置';
  static const String featureLinear = '线性';
  static const String featureUnknown = '未知';
  static const String inputBattery = '电池';
  static const String inputRSSI = '信号强度';
  static const String inputButton = '按钮';
  static const String inputPressure = '压力';
  static const String inputDepth = '深度';
  static const String inputPosition = '位置';
  static const String inputUnknown = '未知';

  // ---- 添加设备类型页面 (add_device_type_page.dart) ----
  static const String chooseDeviceType = '选择设备类型';
  static const String advancedDeviceManagersHint = '高级设备管理器可在"应用模式"面板的"高级设置"中启用。';
  static const String simulatedDevices = '模拟设备';
  static const String simulatedDevicesDesc = '添加/管理基于内置模板的虚拟测试设备';
  static const String websocketDevices = 'WebSocket 设备';
  static const String websocketDevicesDesc = '通过 WebSocket 协议添加/管理设备';
  static const String serialPortDevices = '串口设备';
  static const String serialPortDevicesDesc = '添加/管理串口设备';

  // ---- 添加串口设备页面 (add_serial_device_page.dart) ----
  static const String manageSerialDevices = '管理串口设备';
  static const String existingSerialDevices = '现有串口设备';
  static const String info = '信息';
  static const String addNewSerialDevice = '添加新串口设备';
  static const String protocolType = '协议类型';
  static const String portName = '端口名称';
  static const String baudRate = '波特率';
  static const String dataBits = '数据位';
  static const String parity = '校验位';
  static const String stopBits = '停止位';
  static const String addSerialDevice = '添加串口设备';

  // ---- 添加模拟设备页面 (add_simulated_device_page.dart) ----
  static const String manageSimulatedDevices = '管理模拟设备';
  static const String existingSimulatedDevices = '现有模拟设备';
  static const String device = '设备';
  static const String addNewSimulatedDevice = '添加新模拟设备';
  static const String deviceType = '设备类型';
  static const String displayNameOptional = '显示名称（可选）';
  static const String addSimulatedDevice = '添加模拟设备';

  // ---- 添加 WebSocket 设备页面 (add_websocket_device_page.dart) ----
  static const String manageWebsocketDevices = '管理 WebSocket 设备';
  static const String existingWebsocketDevices = '现有 WebSocket 设备';
  static const String name = '名称';
  static const String addNewWebsocketDevice = '添加新 WebSocket 设备';
  static const String deviceAddress = '设备地址';
  static const String addWebsocketDevice = '添加 WebSocket 设备';

  // ---- 应用模式页面 (app_control_page.dart) ----
  static String appMode(String value) => '应用模式：$value';

  // ---- 日志页面 (log_page.dart) ----
  static const String logOptions = '日志选项';
  static const String logLevel = '日志级别';

  // ---- 设置页面 (settings_page.dart) ----
  static const String helpAbout = '帮助 / 关于';
  static const String experimentalFeatures = '实验性功能';
  static const String restServer = 'REST 服务器';
  static const String usePrereleaseVersion = '使用预发布（测试版）';
  static const String advancedMobileSettings = '高级移动设置';
  static const String appNeedsRestart = '应用需要重启';
  static const String foregroundRestartMessage = '切换前台进程模式需要重启应用。请关闭并重新打开应用以使用前台进程。';
  static const String useForegroundProcess = '使用前台进程';
  static const String requestBluetoothPermissions = '请求蓝牙权限';
  static const String bluetoothPermissionsGranted = '蓝牙权限已授予';
  static const String settingsUnavailableWhileRunning = '服务器运行时部分设置可能不可用。';

  // ---- 引擎配置 (engine_config_widget.dart) ----
  static const String serverSettings = '服务器设置';
  static const String startServerOnLaunch = '启动 Intiface Central 时自动启动服务器';
  static const String serverName = '服务器名称';
  static const String serverNameEntry = '输入服务器名称';
  static const String serverPort = '服务器端口';
  static const String serverPortEntry = '输入服务器端口';
  static const String listenAllInterfaces = '监听所有网络接口';
  static const String deviceManagers = '设备管理器';
  static const String bluetoothLE = '蓝牙 LE';
  static const String xboxGamepad = 'XBox 兼容手柄 (XInput)';
  static const String hidDevices = 'HID 设备 (Joycon 等)';
  static const String lovenseConnectDeprecated = 'Lovense Connect 服务（已弃用）';
  static const String lovenseConnectDeprecatedTitle = 'Lovense Connect 服务已弃用';
  static const String lovenseConnectDeprecatedMsg = 'Lovense Connect 服务已弃用，将在下一版 Intiface Central 中移除。';
  static const String lovenseDongleDeprecatedTitle = 'Lovense USB 适配器已弃用';
  static const String lovenseDongleDeprecatedMsg = 'Lovense USB 适配器设备管理器已弃用，将在下一版 Intiface Central 中移除。';
  static const String lovenseHIDDongle = 'Lovense USB 适配器 (HID/白色电路板)（已弃用）';
  static const String lovenseSerialDongle = 'Lovense USB 适配器 (串口/黑色电路板)（已弃用）';
  static const String otherManagersInAdvanced = '其他设备管理器在下方高级设置中';
  static const String showAdvancedSettings = '显示高级/实验性设置';
  static const String broadcastMdns = '通过 mDNS 广播服务器信息';
  static const String mdnsSuffix = 'mDNS 标识符后缀（可选）';
  static const String mdnsSuffixEntry = '输入 mDNS 后缀';
  static const String advancedExperimentalSettings = '高级/实验性设置';
  static const String advancedDeviceManagers = '高级设备管理器';
  static const String deviceWebsocketServer = '设备 WebSocket 服务器';
  static const String serialPort = '串口';

  // ---- 中继器配置 (repeater_config_widget.dart) ----
  static const String repeaterSettings = '中继器设置';
  static const String repeaterPort = '中继器端口';
  static const String localPort = '本地端口';
  static const String remoteServerAddress = '远程服务器地址';

  // ---- REST API 配置 (rest_api_config_widget.dart) ----
  static const String restApiSettings = 'REST API 设置';
  static const String restApiPort = 'REST API 端口';

  // ---- 应用设置 (settings_app_widget.dart) ----
  static const String theme = '主题';
  static const String themeSystem = '跟随系统';
  static const String themeLight = '浅色';
  static const String themeDark = '深色';
  static const String sideNavigationBar = '侧边导航栏';
  static const String checkUpdatesOnLaunch = '启动时检查更新';
  static const String crashReporting = '崩溃报告';
  static const String sendLogsToDevelopers = '发送日志给开发者';
  static const String restoreWindowLocation = '启动时恢复窗口位置';
  static const String enableDiscordRichPresence = '启用 Discord 丰富状态';
  static const String trayIconNone = '无托盘图标';
  static const String trayIconTaskbar = '托盘 + 任务栏';
  static const String trayIconOnly = '仅托盘';
  static const String systemTrayIcon = '系统托盘图标';
  static const String appSettings = '应用设置';

  // ---- 重置设置 (settings_reset_widget.dart) ----
  static const String wouldYouLikeToContinue = '确定要继续吗？';
  static const String resetApplication = '重置应用';
  static const String resetUserDeviceConfigTitle = '重置用户设备配置';
  static const String resetUserDeviceConfigDesc = '这将清除用户设备配置（存储每个设备的信息）。建议在此步骤后停止并重新启动应用。';
  static const String resetUserDeviceConfig = '重置用户设备配置';
  static const String resetAppToDefaultsTitle = '重置应用至默认设置';
  static const String resetAppToDefaultsDesc = '这将清除所有配置和下载的引擎/配置文件。建议在此步骤后停止并重新启动应用。';
  static const String resetAppConfig = '重置应用配置';

  // ---- 版本更新 (settings_version_widget.dart) ----
  static const String downloadingUpdate = '正在下载更新';
  static const String downloadingUpdateMsg = '正在下载更新。下载完成后 Intiface Central 将关闭并运行安装程序。点击取消可停止下载。';
  static String desktopUpdateAvailable(String version) => 'Intiface Central 桌面版 $version 已可用，点击此处立即更新。';
  static const String manualDownloadHint = '如果自动更新不成功，或想手动安装，点击此处访问下载站点。';
  static String nonWindowsUpdateAvailable(String version) => 'Intiface Central 桌面版 $version 已可用，点击此处访问发布页面。';
  static const String versionsAndUpdates = '版本与更新';
  static const String appVersion = '应用版本';
  static const String deviceConfigVersion = '设备配置版本';
  static const String checkForAppAndConfigUpdates = '检查应用和配置更新';
  static const String checkForConfigUpdates = '检查配置更新';

  // ---- 提交日志 (submit_logs_page.dart) ----
  static const String sendLogsToDevs = '发送日志给开发者';
  static const String submitLogsDescription = '请添加您的联系方式（邮箱、Discord、Telegram、X/Twitter、Bluesky、Mastodon 等…未提供联系方式的提交将被忽略。）以及您希望开发者了解的问题信息。Intiface Central 日志和配置文件将自动附带。';
  static const String putContactInfo = '在此输入联系方式';
  static const String putIssueReport = '在此输入问题报告';
  static const String sendLogs = '发送日志...';
  static const String sendingLogs = '正在发送日志...';
  static const String logsSent = '日志已发送！';
  static const String errorSendingLogs = '发送日志失败，请重试。';

  // ---- 关于/帮助 (about_help_page.dart) ----
  static const String needHelp = '需要帮助？';
  static const String sendLogsForSupport = '发送日志给开发者以获取支持。';

  // ---- 设备列表卡片 (device_list_card_widget.dart) ----
  static const String allow = '允许';
  static const String deny = '拒绝';

  // ---- 新闻卡片 (news_card_widget.dart) ----
  static const String noNewsAvailable = '暂无新闻。';
  static const String showMorePosts = '显示更多帖子';

  // ---- 设备观测 (observation_chart_widget.dart) ----
  static String deviceOutputObservation(int deviceIndex, int featureIndex) =>
      '设备输出观测 $deviceIndex:$featureIndex';

  // ---- 错误加载配置 (intiface_central_app.dart) ----
  static const String errorLoadingConfigs = '加载配置出错';
  static const String errorLoadingConfigsMsg = 'Intiface Central 配置文件无法加载。已删除并恢复默认设置。用户自定义的配置需要重新设置。建议关闭并重新打开 Intiface Central。';

  // ---- 托盘菜单 ----
  static const String trayStartServer = '启动服务器';
  static const String trayStopServer = '停止服务器';

  /// 从 context 获取本地化实例（扩展方法备用）
  static const IntifaceLocalizations instance = IntifaceLocalizations._();
}

/// 便捷扩展，通过 BuildContext 获取本地化字符串
extension IntifaceLocalizationsExt on BuildContext {
  IntifaceLocalizations get loc => IntifaceLocalizations.instance;
}
