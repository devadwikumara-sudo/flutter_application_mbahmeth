import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';

/// Tombol utama dengan gradient, animasi tekan, state loading,
/// dan dukungan ikon.
class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isOutlined;    // Varian outlined (border hijau, bg transparan)
  final Color? backgroundColor;
  final double height;
  final double? width;
  final double borderRadius;
  final double fontSize;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.height = 56,
    this.width,
    this.borderRadius = 16,
    this.fontSize = 16,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed == null || widget.isLoading) return;
    HapticFeedback.lightImpact();
    _scaleCtrl.animateTo(0.95,
        duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
  }

  void _onTapUp(_) {
    _scaleCtrl.animateTo(1.0,
        duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
  }

  void _onTapCancel() {
    _scaleCtrl.animateTo(1.0,
        duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null || widget.isLoading;

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap:
            disabled ? null : () => widget.onPressed?.call(),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: disabled && !widget.isLoading ? 0.55 : 1.0,
          child: Container(
            height: widget.height,
            width: widget.width ?? double.infinity,
            decoration: widget.isOutlined
                ? BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: AppColors.primaryGreen,
                      width: 2,
                    ),
                  )
                : BoxDecoration(
                    gradient: widget.backgroundColor != null
                        ? null
                        : AppColors.brandGradient,
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    boxShadow: disabled
                        ? null
                        : [
                            BoxShadow(
                              color:
                                  AppColors.primaryGreen.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
            alignment: Alignment.center,
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isOutlined
                            ? AppColors.primaryGreen
                            : Colors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null && _isIconLeading) ...[
                        widget.icon!,
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.w700,
                          color: widget.isOutlined
                              ? AppColors.primaryGreen
                              : Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (widget.icon != null && !_isIconLeading) ...[
                        const SizedBox(width: 10),
                        widget.icon!,
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // Ikon selalu di kiri (bisa diextend nanti)
  bool get _isIconLeading => true;
}

/// Varian sekunder — background abu/putih dengan teks hijau
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      icon: icon != null
          ? Icon(icon, color: AppColors.primaryGreen, size: 20)
          : null,
      isOutlined: true,
      height: height,
    );
  }
}

/// Varian kecil — cocok untuk aksi inline (misal "Pesan Lagi")
class SmallPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;

  const SmallPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      icon: icon != null
          ? Icon(icon,
              color: isOutlined ? AppColors.primaryGreen : Colors.white,
              size: 16)
          : null,
      isOutlined: isOutlined,
      height: 40,
      borderRadius: 12,
      fontSize: 13,
    );
  }
}