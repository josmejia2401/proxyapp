import 'package:flutter/material.dart';
import 'package:proxyapp/core/constants/app_colors.dart';
import 'package:proxyapp/routes.dart';
import 'package:proxyapp/shared/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> fade;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    fade = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: Center(
        child: FadeTransition(
          opacity: fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(size: 150),
              const SizedBox(height: 20),
              Text(
                "Tu red. Tus reglas.",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
