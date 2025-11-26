import 'package:flutter/material.dart';
import 'package:start_temp/constants/colors.dart';
import '../../widgets/custom_text_field.dart';

class LoginFields extends StatelessWidget {
  final bool isLogin;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;

  const LoginFields({
    super.key,
    required this.isLogin,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.obscurePassword,
    required this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isLogin) ...[
          CustomTextField(
            controller: nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
        ],
        CustomTextField(
          controller: emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          obscureText: obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary,
            ),
            onPressed: onTogglePassword,
          ),
        ),
      ],
    );
  }
}
