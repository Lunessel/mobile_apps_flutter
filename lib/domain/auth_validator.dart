abstract final class AuthValidator {
  static String? name(String value) {
    if (value.trim().isEmpty) return "Ім'я не може бути порожнім";
    if (value.contains(RegExp(r'\d'))) {
      return "Ім'я не може містити цифри";
    }
    return null;
  }

  static String? email(String value) {
    if (value.trim().isEmpty) return 'Email не може бути порожнім';
    if (!value.contains('@')) return 'Email має містити @';
    if (!value.contains('.')) return 'Email має містити крапку';
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return 'Пароль не може бути порожнім';
    if (value.length < 6) {
      return 'Пароль має бути мінімум 6 символів';
    }
    return null;
  }

  static String? confirmPassword(String pass, String confirm) {
    if (pass != confirm) return 'Паролі не співпадають';
    return null;
  }
}
