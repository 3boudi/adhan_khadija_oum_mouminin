import 'package:flutter/material.dart';
import 'package:arabic_font/arabic_font.dart';
import '../utils/app_exceptions.dart';

class ErrorRetryWidget extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const ErrorRetryWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    String errorMessage = 'حدث خطأ غير متوقع';
    String errorTitle = 'خطأ';
    IconData errorIcon = Icons.error_outline;

    if (error is AppException) {
      errorMessage = (error as AppException).message;
      errorTitle = (error as AppException).title ?? 'تنبيه';

      if (error is LocationDisabledException ||
          error is LocationPermissionDeniedException ||
          error is LocationPermissionPermanentlyDeniedException) {
        errorIcon = Icons.location_off;
      } else if (error is NetworkException) {
        errorIcon = Icons.wifi_off;
      } else if (error is DataNotFoundException) {
        errorIcon = Icons.cloud_off;
      }
    } else {
      errorMessage = error.toString();
    }

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  errorIcon,
                  color: Colors.red[700],
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                errorTitle,
                textAlign: TextAlign.center,
                style: ArabicTextStyle(
                  arabicFont: ArabicFont.dinNextLTArabic,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: ArabicTextStyle(
                  arabicFont: ArabicFont.dinNextLTArabic,
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 24, 84, 0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'إعادة المحاولة',
                    style: ArabicTextStyle(
                      arabicFont: ArabicFont.dinNextLTArabic,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
