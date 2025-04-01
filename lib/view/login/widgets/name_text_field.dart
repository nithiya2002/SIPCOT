import 'package:flutter/material.dart';
import '../../../utility/widget/text_form_reusable/reusable_textform_field.dart';
import '../../../viewModel/login_vm.dart';

class NameTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  const NameTextField({
    super.key,
    required this.controller,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  State<NameTextField> createState() => _NameTextFieldState();
}

class _NameTextFieldState extends State<NameTextField> {
  final LoginVm _loginVm = LoginVm();

  @override
  Widget build(BuildContext context) {
    return ReusableTextFormField(
      labelText: 'Name',
      hintText: 'Enter your name',
      prefixIcon: Icons.person,
      keyboardType: TextInputType.name,
      controller: widget.controller,
      validator: (value) {
        final validator = _loginVm.nameValidator;
        return validator(value);
      },
      focusNode: widget.focusNode,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}
