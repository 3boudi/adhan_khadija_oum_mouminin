class AppException implements Exception {
  final String message;
  final String? title;

  AppException(this.message, {this.title});

  @override
  String toString() => message;
}

class LocationDisabledException extends AppException {
  LocationDisabledException()
      : super('تم إيقاف خدمات الموقع. يرجى تفعيلها من الإعدادات.',
            title: 'الموقع معطل');
}

class LocationPermissionDeniedException extends AppException {
  LocationPermissionDeniedException()
      : super(
            'تم رفض إذن الوصول للموقع. التطبيق يحتاج للموقع لحساب أوقات الصلاة.',
            title: 'الإذن مطلوب');
}

class LocationPermissionPermanentlyDeniedException extends AppException {
  LocationPermissionPermanentlyDeniedException()
      : super(
            'تم رفض إذن الموقع بشكل دائم. يرجى تفعيل الإذن يدوياً من إعدادات التطبيق.',
            title: 'الإذن مطلوب');
}

class NetworkException extends AppException {
  NetworkException()
      : super(
            'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى.',
            title: 'خطأ في الاتصال');
}

class DataNotFoundException extends AppException {
  DataNotFoundException()
      : super('لا توجد بيانات محفوظة وتوفر الإنترنت غير متاح.',
            title: 'لا توجد بيانات');
}

class GeneralException extends AppException {
  GeneralException([String? message])
      : super(message ?? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
            title: 'خطأ');
}
