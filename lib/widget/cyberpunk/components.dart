import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intiface_central/theme/cyberpunk.dart';

/// 极光渐变背景
///
/// 双径向渐变(青色+品红)叠加在深紫黑底色上，营造赛博朋克氛围。
/// 作为 Stack 的最底层使用。
class AuroraBackground extends StatelessWidget {
  final Widget? child;

  const AuroraBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 底色
        Container(color: CyberColors.background),
        // 青色光晕 — 左上
        Positioned(
          left: -100,
          top: -50,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  CyberColors.auroraCyan.withOpacity(0.15),
                  CyberColors.auroraCyan.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        // 品红光晕 — 右下
        Positioned(
          right: -80,
          bottom: 100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  CyberColors.auroraMagenta.withOpacity(0.12),
                  CyberColors.auroraMagenta.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        // 紫色光晕 — 右上(辅助)
        Positioned(
          right: -60,
          top: 200,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  CyberColors.accent.withOpacity(0.08),
                  CyberColors.accent.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}

/// 毛玻璃卡片
///
/// 半透明填充 + 背景模糊 + 霓虹内发光边框，visionOS级质感。
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? blurRadius;
  final Color? glowColor;
  final Color? borderColor;
  final double? borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.blurRadius,
    this.glowColor,
    this.borderColor,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? CyberRadius.card;
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurRadius ?? CyberEffects.blurRadius,
          sigmaY: blurRadius ?? CyberEffects.blurRadius,
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(CyberSpacing.xl),
          decoration: BoxDecoration(
            color: CyberColors.glassFill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ?? CyberColors.glassBorder,
              width: 1,
            ),
            boxShadow: [
              if (glowColor != null)
                BoxShadow(
                  color: glowColor!.withOpacity(0.08),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: CyberEffects.cardShadowRadius,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return Container(margin: margin, child: card);
  }
}

/// 霓虹按钮 (胶囊形)
class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool filled;
  final double? width;
  final double height;

  const NeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.filled = true,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? CyberColors.primary;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.xl),
        decoration: BoxDecoration(
          color: filled ? accent : accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(CyberRadius.pill),
          border: Border.all(
            color: filled ? Colors.transparent : accent.withOpacity(0.3),
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.3),
                    blurRadius: CyberEffects.glowRadius,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: width != null ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: filled ? CyberColors.background : accent),
              const SizedBox(width: CyberSpacing.sm),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: filled ? CyberColors.background : accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 赛博开关
class CyberToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const CyberToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? CyberColors.primary;
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? color : CyberColors.textDisabled,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 霓虹滑块
class CyberSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final Color? trackColor;
  final Color? glowColor;

  const CyberSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.trackColor,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final tColor = trackColor ?? CyberColors.secondary;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: tColor,
        inactiveTrackColor: Colors.white.withOpacity(0.08),
        thumbColor: Colors.white,
        overlayColor: tColor.withOpacity(0.12),
        trackHeight: 8,
        thumbShape: _NeonThumbShape(glowColor: glowColor ?? tColor),
      ),
      child: Slider(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _NeonThumbShape extends RoundSliderThumbShape {
  final Color glowColor;
  const _NeonThumbShape({this.glowColor = CyberColors.secondary})
      : super(enabledThumbRadius: 10, elevation: 4);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    // 发光层
    final glowPaint = Paint()
      ..color = glowColor.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);
    context.canvas.drawCircle(center, 10, glowPaint);
    // 主体
    super.paint(
      context,
      center,
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
    );
    // 内发光
    final innerPaint = Paint()
      ..color = glowColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 2);
    context.canvas.drawCircle(center, 10, innerPaint);
  }
}

/// 页面标题栏
class CyberHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final Widget? trailing;

  const CyberHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.xl, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CyberTextStyles.pageTitle),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor ?? CyberColors.primary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 胶囊底部导航
class PillBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PillBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: CyberSpacing.xl),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF050518).withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: CyberColors.glassBorderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.play_arrow_rounded,
                label: '运行',
                index: 0,
                currentIndex: currentIndex,
                color: CyberColors.primary,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.widgets_outlined,
                label: '设备',
                index: 1,
                currentIndex: currentIndex,
                color: CyberColors.primary,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.receipt_long_outlined,
                label: '日志',
                index: 2,
                currentIndex: currentIndex,
                color: CyberColors.secondary,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                label: '设置',
                index: 3,
                currentIndex: currentIndex,
                color: CyberColors.accent,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Color color;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isActive
              ? Border.all(color: color.withOpacity(0.4))
              : Border.all(color: Colors.transparent),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? color : CyberColors.textDisabled,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? color : CyberColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 设置行 (图标 + 标签 + 右侧控件/箭头)
class CyberSettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const CyberSettingRow({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CyberRadius.small),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor ?? CyberColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CyberColors.textSecondary,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// 卡片标题
class CyberCardTitle extends StatelessWidget {
  final String text;
  final Color? color;

  const CyberCardTitle({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color ?? CyberColors.textTertiary,
      ),
    );
  }
}
