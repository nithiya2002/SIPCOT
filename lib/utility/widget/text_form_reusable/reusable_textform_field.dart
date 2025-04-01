import 'package:flutter/material.dart';

class ReusableTextFormField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final bool obscureText;
  final VoidCallback? onSuffixIconPressed;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  const ReusableTextFormField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    required this.controller,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.onSuffixIconPressed,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  State<ReusableTextFormField> createState() => _ReusableTextFormFieldState();
}

class _ReusableTextFormFieldState extends State<ReusableTextFormField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: OutlineInputBorder(),
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon:
            widget
                    .obscureText // Check if it's password field
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ), // Change icon based on _obscureText
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : widget.suffixIcon != null
                ? IconButton(
                  icon: Icon(widget.suffixIcon),
                  onPressed:
                      widget.onSuffixIconPressed ??
                      () {
                        if (widget.controller.text.isNotEmpty) {
                          widget.controller.clear();
                          setState(() {});
                        }
                      },
                )
                : widget.controller.text.isNotEmpty
                ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                    setState(() {});
                  },
                )
                : null,
      ),
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}
