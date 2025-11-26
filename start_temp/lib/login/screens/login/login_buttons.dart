import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class LoginButtons extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onSubmit;

  const LoginButtons({
    super.key,
    required this.isLogin,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onSubmit,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        child: Text(
          style: const TextStyle(color: AppColors.textPrimary),
          isLogin ? 'Sign In' : 'Create Account',
        ),
      ),
    );
  }
}
