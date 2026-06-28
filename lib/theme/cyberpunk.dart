import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

/// 赛博朋克设计系统 — 设计令牌
///
/// 对照 Ardot 设计稿 "Intiface赛博朋克移动端重设计" 的色彩与排版规范。
/// 深紫黑底色 + 青色/品红双霓虹强调 + 极光径向渐变 + visionOS级毛玻璃。

class CyberColors {
  CyberColors._();

  // ── 背景层 ──
  /// 主背景 深紫黑 #000010
  static const Color background = Color(0xFF000010);

  /// 极光渐变 — 青色光晕
  static const Color auroraCyan = Color(0xFF00F0FF);

  /// 极光渐变 — 品红光晕
  static const Color auroraMagenta = Color(0xFFFF00E5);

  // ── 强调色 ──
  /// 主强调色 霓虹青 (连接/运行状态)
  static const Color primary = Color(0xFF00F0FF);

  /// 副强调色 霓虹品红 (控制/滑块)
  static const Color secondary = Color(0xFFFF00E5);

  /// 紫色 (设置/关于)
  static const Color accent = Color(0xFFA080FF);

  // ── 语义色 ──
  static const Color success = Color(0xFF00FF80);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF5050);
  static const Color info = Color(0xFF5590FF);

  // ── 文字色 ──
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCCCCCC);
  static const Color textTertiary = Color(0xFF9999AA);
  static const Color textDisabled = Color(0xFF666688);

  // ── 表面层 ──
  /// 毛玻璃卡片填充 (白色 6% 透明度)
  static Color glassFill = Colors.white.withOpacity(0.06);

  /// 毛玻璃卡片填充 (浅色 3%)
  static Color glassFillSubtle = Colors.white.withOpacity(0.03);

  /// 卡片描边 (白色 15%)
  static Color glassBorder = Colors.white.withOpacity(0.15);

  /// 卡片描边 (浅色 8%)
  static Color glassBorderSubtle = Colors.white.withOpacity(0.08);

  // ── 渐变 ──
  /// 震动滑块轨道渐变 (橙→品红)
  static const List<Color> sliderVibrationGradient = [
    Color(0xFFFF8000),
    Color(0xFFFF00E5),
  ];

  /// 电池条渐变 (青→绿)
  static const List<Color> batteryGoodGradient = [
    Color(0xFF00F0FF),
    Color(0xFF00FF80),
  ];

  /// 电池条渐变 (橙→品红，低电量)
  static const List<Color> batteryLowGradient = [
    Color(0xFFFF8000),
    Color(0xFFFF00E5),
  ];
}

class CyberSpacing {
  CyberSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class CyberRadius {
  CyberRadius._();

  /// 卡片圆角
  static const double card = 20;

  /// 胶囊按钮圆角
  static const double pill = 99;

  /// 输入框圆角
  static const double input = 12;

  /// 小元素圆角
  static const double small = 10;
}

class CyberEffects {
  CyberEffects._();

  /// 毛玻璃模糊半径
  static const double blurRadius = 50;

  /// 霓虹发光阴影半径
  static const double glowRadius = 12;

  /// 卡片投影半径
  static const double cardShadowRadius = 24;
}

/// 赛博朋克文字样式
class CyberTextStyles {
  CyberTextStyles._();

  /// 大标题 (页面标题)
  static const TextStyle pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: CyberColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// 副标题 (英文标签)
  static const TextStyle subtitle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: CyberColors.primary,
    letterSpacing: 2,
  );

  /// 卡片标题
  static const TextStyle cardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: CyberColors.textSecondary,
  );

  /// 设备名称
  static const TextStyle deviceName = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: CyberColors.textPrimary,
  );

  /// 正文
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: CyberColors.textSecondary,
  );

  /// 小字标签
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: CyberColors.textTertiary,
  );

  /// 数值 (滑块百分比等)
  static const TextStyle valueBold = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  /// 底部导航标签
  static const TextStyle navLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  /// 底部导航选中标签
  static const TextStyle navLabelActive = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
}

/// flutter_settings_ui 暗色主题 — 匹配赛博朋克风格
///
/// 覆盖 SettingsList 默认的灰底/灰卡片，使其融入极暗紫黑背景 + 毛玻璃质感。
final SettingsThemeData cyberpunkSettingsTheme = SettingsThemeData(
  settingsListBackground: Colors.transparent,
  settingsSectionBackground: Colors.transparent,
  titleTextColor: CyberColors.primary,
  settingsTileTextColor: CyberColors.textSecondary,
  inactiveTitleColor: CyberColors.textDisabled,
  inactiveSubtitleColor: CyberColors.textDisabled,
  trailingTextColor: CyberColors.textTertiary,
  leadingIconsColor: CyberColors.textTertiary,
  dividerColor: CyberColors.glassBorderSubtle,
  tileHighlightColor: Color(0x0AFFFFFF),
  tileDescriptionTextColor: CyberColors.textTertiary,
);

/// 构建赛博朋克暗色主题
ThemeData buildCyberpunkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: CyberColors.background,
    colorScheme: const ColorScheme.dark(
      primary: CyberColors.primary,
      secondary: CyberColors.secondary,
      surface: CyberColors.background,
      error: CyberColors.error,
      onPrimary: CyberColors.background,
      onSecondary: CyberColors.background,
      onSurface: CyberColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: CyberColors.textPrimary,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CyberRadius.card),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CyberRadius.input),
        borderSide: BorderSide(color: CyberColors.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CyberRadius.input),
        borderSide: BorderSide(color: CyberColors.glassBorderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CyberRadius.input),
        borderSide: const BorderSide(color: CyberColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: CyberColors.secondary,
      inactiveTrackColor: Colors.white.withOpacity(0.08),
      thumbColor: Colors.white,
      overlayColor: CyberColors.secondary.withOpacity(0.12),
      trackHeight: 8,
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 10,
        elevation: 4,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.white.withOpacity(0.3);
        }
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return CyberColors.primary.withOpacity(0.12);
        }
        return states.contains(WidgetState.selected)
            ? CyberColors.primary
            : Colors.white.withOpacity(0.15);
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.transparent;
        }
        return states.contains(WidgetState.selected)
            ? Colors.transparent
            : Colors.white.withOpacity(0.1);
      }),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: CyberColors.primary,
      unselectedItemColor: CyberColors.textDisabled,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(
      space: 1,
      thickness: 0.5,
      color: CyberColors.glassBorderSubtle,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF0A0A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CyberRadius.card),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF0A0A1A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CyberRadius.input),
      ),
    ),
  );
}
