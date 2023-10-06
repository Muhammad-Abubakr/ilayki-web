import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ilayki_web/pages/loginpage.dart';
import 'package:image_picker_web/image_picker_web.dart';

import '../blocs/authenticate/authenticate_bloc.dart';

class RegisterPage extends StatefulWidget {
  static const route = '/register';

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Uint8List? _pfp;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final scaffoldMessengerState = ScaffoldMessenger.of(context);
    final navigatorState = Navigator.of(context);
    final themeData = Theme.of(context);
    final AuthenticateBloc authBloc = BlocProvider.of<AuthenticateBloc>(context);

    return BlocListener<AuthenticateBloc, AuthenticateState>(
      listener: (context, state) {
        if (state is AuthProcessing) {
          navigatorState.push(DialogRoute(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
          ));
        } else if (state is AuthError) {
          navigatorState.popUntil((route) => route.settings.name == RegisterPage.route);
          scaffoldMessengerState.showSnackBar(SnackBar(
            content: Text(
              "${state.error?.message}",
              textAlign: TextAlign.center,
            ),
          ));
        } else if (state is DatabaseException) {
          navigatorState.popUntil((route) => route.settings.name == RegisterPage.route);
          scaffoldMessengerState.showSnackBar(SnackBar(
            content: Text(
              "${state.exception?.message}",
              textAlign: TextAlign.center,
            ),
          ));
        } else if (state is AuthRegistered) {
          navigatorState.popUntil((route) => route.settings.name == RegisterPage.route);
          navigatorState.popAndPushNamed(LoginPage.route);
        }
      },
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 500,
            height: 650,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 64.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          "Register",
                          style: themeData.textTheme.displayLarge?.copyWith(
                            fontFamily: GoogleFonts.kaushanScript().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 64),

                        /// Registeration Details
                        TextField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            label: Text("Name"),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            label: Text("Email"),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            label: Text("Password"),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildImagePicker(),

                        /// Hint for Changing image after Selection
                        if (_pfp != null) ...[
                          const SizedBox(height: 8),
                          const Text(
                            "Tip: Tap on image again to change",
                            style: TextStyle(
                              // fontSize: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (_nameController.text.isNotEmpty &&
                                _emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty &&
                                _pfp != null) {
                              authBloc.add(
                                RegisterEvent(
                                  displayName: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  pfp: _pfp!,
                                ),
                              );
                            }
                          },
                          child: const Text("Register"),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () =>
                              navigatorState.pushReplacementNamed(LoginPage.route),
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _pickImage() async {
    final picked = await ImagePickerWeb.getImageAsBytes();
    if (picked != null) {
      setState(() => _pfp = picked);
    }
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      /* image_picker */
      onTap: () => _pickImage(),
      /* Container */
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          image: _pfp != null
              ? DecorationImage(
                  image: Image.memory(_pfp!).image,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        padding: const EdgeInsets.all(1),
        width: 128,
        height: 128,
        /* Picture Update */
        child: _pfp == null
            ? const Text(
                "Tap here to add a profile picture",
                textAlign: TextAlign.center,
              )
            : null,
      ),
    );
  }
}
