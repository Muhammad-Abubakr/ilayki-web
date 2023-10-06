import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ilayki_web/pages/registerpage.dart';

import '../dashboard.dart';
import '../blocs/authenticate/authenticate_bloc.dart';

class LoginPage extends StatefulWidget {
  static const route = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
        if (state is AuthSuccessful) {
          navigatorState.popUntil((route) => route.settings.name == LoginPage.route);
          navigatorState.pushReplacementNamed(Dashboard.route);
        } else if (state is AuthProcessing) {
          navigatorState.push(DialogRoute(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
          ));
        } else if (state is AuthError) {
          navigatorState.popUntil((route) => route.settings.name == LoginPage.route);
          scaffoldMessengerState.showSnackBar(SnackBar(
            content: Text(
              "${state.error?.message}",
              textAlign: TextAlign.center,
            ),
          ));
        } else if (state is AuthReset) {
          navigatorState.popUntil((route) => route.settings.name == LoginPage.route);
        }
      },
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 400,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          "Ilayki",
                          style: themeData.textTheme.displayLarge?.copyWith(
                            fontFamily: GoogleFonts.kaushanScript().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 48),
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
                        ElevatedButton(
                          onPressed: () => authBloc.add(
                            LoginEvent(
                                email: _emailController.text,
                                password: _passwordController.text),
                          ),
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () =>
                              navigatorState.pushReplacementNamed(RegisterPage.route),
                          child: const Text("Register"),
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
}
