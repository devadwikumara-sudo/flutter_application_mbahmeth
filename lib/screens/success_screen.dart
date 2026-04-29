import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SuccessScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onPressed;

  const SuccessScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.onPressed,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Automatically trigger onPressed after 2 seconds
    _timer = Timer(const Duration(seconds: 2), () {
      if (widget.onPressed != null && mounted) {
        widget.onPressed!();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: GestureDetector(
        onTap: () {
          _timer?.cancel();
          if (widget.onPressed != null) {
            widget.onPressed!();
          }
        },
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: AppColors.primaryGreen,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
