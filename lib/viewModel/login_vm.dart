import 'package:flutter/material.dart';

class LoginVm extends ChangeNotifier {
  String? Function(String?) get nameValidator {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'This field is required';
      }
      if (value.length != value.replaceAll(' ', '').length) {
        return 'Username must not contain any spaces';
      }
      if (int.tryParse(value[0]) != null) {
        return 'Username must not start with a number';
      }
      if (value.length <= 2) {
        return 'Username should be at least 3 characters long';
      }
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
        return 'Only letters, numbers and underscore are allowed';
      }
      return null;
    };
  }

  String? Function(String?) get emailValidator {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your email';
      }
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'Please enter a valid email';
      }
      return null;
    };
  }

  String? Function(String?) get passwordValidator {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your password';
      }
      if (value.length < 8) {
        return 'Password must be at least 8 characters';
      }
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return 'Password must contain at least one uppercase letter';
      }
      if (!RegExp(r'[a-z]').hasMatch(value)) {
        return 'Password must contain at least one lowercase letter';
      }
      if (!RegExp(r'[0-9]').hasMatch(value)) {
        return 'Password must contain at least one number';
      }
      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
        return 'Password must contain at least one special character';
      }
      return null;
    };
  }
}
