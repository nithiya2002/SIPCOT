import 'package:flutter/material.dart';

import '../../../utility/widget/text_form_reusable/reusable_textform_field.dart';
import '../../../viewModel/login_vm.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  final LoginVm _loginVm = LoginVm();

  @override
  Widget build(BuildContext context) {
    return ReusableTextFormField(
      labelText: 'Password',
      hintText: 'Enter your password',
      prefixIcon: Icons.password,
      suffixIcon: Icons.visibility,
      obscureText: true,
      controller: widget.controller,
      validator: (value) {
        final validator = _loginVm.passwordValidator;
        return validator(value);
      },
      focusNode: widget.focusNode,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}
