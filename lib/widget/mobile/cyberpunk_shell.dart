import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/util/navigation_cubit.dart';
import 'package:intiface_central/page/mobile/cyberpunk_about_page.dart';
import 'package:intiface_central/page/mobile/cyberpunk_send_logs_page.dart';
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
        return const CyberpunkAboutPage();
      case NavigationPage.sendLogs:
        return const CyberpunkSendLogsPage();
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

        // 全屏页面 (关于/帮助/发送日志) — 带返回按钮，无底部导航
        if (isFullScreen) {
          final title = switch (page) {
            NavigationPage.about || NavigationPage.help => '关于与帮助',
            NavigationPage.sendLogs => '发送日志',
            _ => '',
          };
          final goBackTo = (page == NavigationPage.sendLogs)
              ? NavigationPage.about
              : NavigationPage.settings;
          return AuroraBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // 返回栏
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CyberSpacing.xl,
                      vertical: CyberSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            final nav = BlocProvider.of<NavigationCubit>(context);
                            switch (goBackTo) {
                              case NavigationPage.about:
                                nav.goAbout();
                              default:
                                nav.goSettings();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(CyberRadius.small),
                              border: Border.all(color: CyberColors.glassBorderSubtle),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_back_ios_new, size: 14, color: CyberColors.textSecondary),
                                SizedBox(width: 4),
                                Text('返回', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: CyberColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: CyberSpacing.lg),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: CyberColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 页面内容 — Expanded 在此 Column 内有效
                  Expanded(child: _buildPage(page)),
                ],
              ),
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
