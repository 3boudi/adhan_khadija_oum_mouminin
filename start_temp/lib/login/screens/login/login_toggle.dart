import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class LoginToggle extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onToggleMode;

  const LoginToggle({
    super.key,
    required this.isLogin,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onToggleMode,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
          children: [
            TextSpan(
              text: isLogin
                  ? 'Don\'t have an account? '
                  : 'Already have an account? ',
            ),
            TextSpan(
              text: isLogin ? 'Sign Up' : 'Sign In',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
