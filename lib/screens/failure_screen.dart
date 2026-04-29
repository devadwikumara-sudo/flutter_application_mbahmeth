import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FailureScreen extends StatefulWidget {
  final String title;
  final VoidCallback? onPressed;

  const FailureScreen({
    super.key,
    required this.title,
    this.onPressed,
  });

  @override
  State<FailureScreen> createState() => _FailureScreenState();
}

class _FailureScreenState extends State<FailureScreen> {
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
      backgroundColor: AppColors.primaryRed,
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
                      Icons.close,
                      color: AppColors.primaryRed,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
