import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sipcot/view/login/widgets/name_text_field.dart';
import 'package:sipcot/view/login/widgets/password_text_field.dart';
import 'package:sipcot/viewModel/auth_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        _validateOnly();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    //   if (_formKey.currentState != null && _formKey.currentState!.validate()) {
    if (_formKey.currentState?.validate() ?? false) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.login(_emailController.text.trim());
    }
  }

  void _validateOnly() {
    _formKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NameTextField(controller: _nameController),
              /*  ReusableTextFormField(
                labelText: "Name",
                hintText: "Enter full Name",
                controller: _nameController,
                prefixIcon: Icons.agriculture_sharp,
                keyboardType: TextInputType.name,
                validator: (value) {
                  return _loginVm.nameValidator()(value);
                },
                textInputAction: TextInputAction.next,
                focusNode: _nameFocus,
                onFieldSubmitted: (value) {
                  _validateOnly();
                },
              ), */
              const SizedBox(height: 16),
              TextFormField(
                // autofocus: true,
                controller: _emailController,
                focusNode: _emailFocus,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                  suffixIcon:
                      _emailController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _emailController.clear();
                              setState(() {});
                            },
                          )
                          : null,
                  // contentPadding: const EdgeInsets.symmetric(
                  //   horizontal: 12,
                  //   vertical: 16,
                  // ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onFieldSubmitted: (value) {
                  _validateOnly();
                },
              ),
              const SizedBox(height: 20),
              if (authViewModel.error != null)
                Text(
                  authViewModel.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              PasswordTextField(controller: _passwordController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: authViewModel.isLoading ? null : _validateAndSubmit,
                child:
                    authViewModel.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
