import 'package:flutter/material.dart';
import '../../../utility/widget/text_form_reusable/reusable_textform_field.dart';
import '../../../viewModel/login_vm.dart';

class EmailTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  const EmailTextField({
    super.key,
    required this.controller,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  final LoginVm _loginVm = LoginVm();

  @override
  Widget build(BuildContext context) {
    return ReusableTextFormField(
      labelText: 'Email',
      hintText: 'Enter your email',
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      controller: widget.controller,
      validator: (value) {
        final validatorFunction = _loginVm.emailValidator;
        return validatorFunction(value);
      },
      focusNode: widget.focusNode,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}
