import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/util/navigation_cubit.dart';
import 'package:intiface_central/page/about_help_page.dart';
import 'package:intiface_central/page/submit_logs_page.dart';
import 'package:intiface_central/page/mobile/cyberpunk_console_page.dart';
import 'package:intiface_central/page/mobile/cyberpunk_device_page.dart';
import 'package:intiface_central/page/mobile/cyberpunk_log_page.dart';
import 'package:intiface_central/page/mobile/cyberpunk_settings_page.dart';
import 'package:intiface_central/theme/cyberpunk.dart';
import 'package:intiface_central/widget/cyberpunk/components.dart';

/// 赛博朋克移动端外壳
///
/// 替换原有的 Column(ControlWidget + BodyWidget) 移动端布局。
/// 包含极光背景、4标签胶囊底部导航(运行/设备/日志/设置)，
/// 以及 About/SendLogs 全屏路由处理。
class CyberpunkMobileShell extends StatelessWidget {
  const CyberpunkMobileShell({super.key});

  /// 将 NavigationPage 映射为底部导航索引 (-1 表示不在主标签中)
  int _pageToIndex(NavigationPage page) {
    switch (page) {
      case NavigationPage.appControl:
        return 0;
      case NavigationPage.deviceControl:
        return 1;
      case NavigationPage.logs:
        return 2;
      case NavigationPage.settings:
        return 3;
      default:
        return -1;
    }
  }

  NavigationPage _indexToPage(int index) {
    switch (index) {
      case 0:
        return NavigationPage.appControl;
      case 1:
        return NavigationPage.deviceControl;
      case 2:
        return NavigationPage.logs;
      case 3:
        return NavigationPage.settings;
      default:
        return NavigationPage.appControl;
    }
  }

  Widget _buildPage(NavigationPage page) {
    switch (page) {
      case NavigationPage.appControl:
        return const CyberpunkConsolePage();
      case NavigationPage.deviceControl:
        return const CyberpunkDevicePage();
      case NavigationPage.logs:
        return const CyberpunkLogPage();
      case NavigationPage.settings:
        return const CyberpunkSettingsPage();
      case NavigationPage.about:
      case NavigationPage.help:
        return const AboutHelpPage();
      case NavigationPage.sendLogs:
        return const SendLogsPage();
      default:
        return const CyberpunkConsolePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationPage>(
      builder: (context, page) {
        final navIndex = _pageToIndex(page);
        final isFullScreen = navIndex == -1;

        // 全屏页面 (关于/发送日志) — 无底部导航
        if (isFullScreen) {
          return AuroraBackground(
            child: SafeArea(
              child: _buildPage(page),
            ),
          );
        }

        return AuroraBackground(
          child: SafeArea(
            child: Column(
              children: [
                // 页面内容 (SafeArea 已处理系统状态栏)
                Expanded(child: _buildPage(page)),
                // 底部导航
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: CyberSpacing.md,
                    top: CyberSpacing.sm,
                  ),
                  child: PillBottomNav(
                    currentIndex: navIndex,
                    onTap: (index) {
                      final navCubit = BlocProvider.of<NavigationCubit>(context);
                      final targetPage = _indexToPage(index);
                      switch (targetPage) {
                        case NavigationPage.appControl:
                          navCubit.goAppControl();
                        case NavigationPage.deviceControl:
                          navCubit.goDeviceControl();
                        case NavigationPage.logs:
                          navCubit.goLogs();
                        case NavigationPage.settings:
                          navCubit.goSettings();
                        default:
                          break;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
