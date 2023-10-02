import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ilayki/blocs/notifications/notifications_cubit.dart';
import 'package:ilayki/blocs/online/online_cubit.dart';
import 'package:ilayki/blocs/orders/orders_cubit.dart';
import 'package:ilayki/blocs/requests/requests_cubit.dart';
import 'package:ilayki/blocs/sales/sales_cubit.dart';
import 'package:ilayki/blocs/user/user_bloc.dart';
import 'package:ilayki/blocs/userchat/userchat_cubit.dart';
import 'package:ilayki/screens/auth/email_verification_screen.dart';
import 'package:ilayki/screens/auth/register_screen.dart';

import '../../app.dart';
import '../../blocs/email_verificaton/email_verification_cubit.dart';
import '../../blocs/localization/localization_cubit.dart';

class LoginScreen extends StatefulWidget {
  // route name
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Text Field Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late EmailVerificationCubit _emailVerificationCubit;

  @override
  void didChangeDependencies() {
    /* Initialize the user stream for email verification cubit */
    _emailVerificationCubit = context.read<EmailVerificationCubit>();
    _emailVerificationCubit.initialize();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // Localization cubit
    final LocalizationCubit cubit = context.watch<LocalizationCubit>();

    /* Locales Dropdown */
    final SupportedLocales dropdownValue = SupportedLocales.values.firstWhere(
      (element) => describeEnum(element) == cubit.state.locale,
    );

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        // In case of error
        switch (state.state) {
          case UserStates.signedIn:
            // clear the controllers
            _emailController.clear();
            _passwordController.clear();

            if (state.user!.emailVerified) {
              /* Initialize the online users */
              context.read<OnlineCubit>().setOnline();

              /* Initialize the requests for current user */
              context.read<RequestsCubit>().initialize();

              /* Initialize the orders for current user */
              context.read<OrdersCubit>().initialize();

              /* Initialize the sales for current user */
              context.read<SalesCubit>().initialize();

              /* Initialize the user chats */
              context.read<UserchatCubit>().intialize();

              /* Initialize the user chats */
              context.read<NotificationsCubit>().initialize();

              // Pop the progress indicator
              Navigator.of(context).popUntil((route) => route.isCurrent);
              // and push the screen
              Navigator.of(context).pushReplacementNamed(App.routeName);
              break;
            }

            /* Send user for Email Verification */
            context
                .read<UserBloc>()
                .add(EmailVerification(context.read<UserBloc>().state.user!));
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const EmailVerificationScreen()),
            );
            context.read<UserBloc>().add(UserSignOut());
            break;
          case UserStates.error:
            // In case of error pop the routes (which will contain progress indicator mostly)
            // until login screen and show the snack bar with the error
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                state.error!.message!,
                textAlign: TextAlign.center,
              ),
            ));
            break;
          case UserStates.processing:
            // Show the Dialog presenting progress indicator
            Navigator.of(context).push(
              DialogRoute(
                barrierDismissible: false,
                context: context,
                builder: (context) => Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
            break;
          case UserStates.registered:
            /* Popping Register Screen off Stack */
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                AppLocalizations.of(context)!.userSuccessfullyRegistered,
                textAlign: TextAlign.center,
              ),
            ));
            break;

          default:
            break;
        }
      },
      child: WillPopScope(
        onWillPop: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmationDialog),
            content: Text(AppLocalizations.of(context)!.confirmationContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () => exit(exitCode),
                child: Text(AppLocalizations.of(context)!.exit),
              ),
            ],
          ),
        ).then((value) => value as bool),
        child: Scaffold(
          /* App Bar */
          appBar: AppBar(
            leading: Padding(
              padding: EdgeInsets.only(left: 24.w),
              child: FittedBox(
                child: Text(
                  AppLocalizations.of(context)!.welcome,
                  style: TextStyle(
                    fontSize: 22.spMax,
                  ),
                ),
              ),
            ),
            leadingWidth: 0.3.sw,
            foregroundColor: const Color.fromARGB(255, 236, 201, 171),
            shadowColor: const Color.fromARGB(255, 244, 217, 185),

            // Locales
            actions: [
              /* Dropdown Button for changing the locale for the application */
              DropdownButton(
                iconSize: 16.spMax,
                elevation: 1,
                value: dropdownValue,

                // Update the cubit state with the locale selected by the user
                onChanged: (value) {
                  if (value != null) cubit.updateLocale(value);
                },
                items: [
                  DropdownMenuItem(
                    alignment: Alignment.center,
                    value: SupportedLocales.en,
                    child: Image.asset(
                      'lib/assets/flags/us.png',
                      fit: BoxFit.scaleDown,
                      height: 16.spMax,
                    ),
                  ),
                  DropdownMenuItem(
                    alignment: Alignment.center,
                    value: SupportedLocales.ar,
                    child: Image.asset(
                      'lib/assets/flags/sa.png',
                      fit: BoxFit.scaleDown,
                      height: 16.spMax,
                    ),
                  ),
                  DropdownMenuItem(
                    alignment: Alignment.center,
                    value: SupportedLocales.fr,
                    child: Image.asset(
                      'lib/assets/flags/fr.png',
                      fit: BoxFit.scaleDown,
                      height: 16.spMax,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: // Form Global Key
              Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: !isLandscape ? 0.08.sw : 0.3.sw,
                vertical: 128.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Ilayki',
                    style: GoogleFonts.kaushanScript(
                      fontSize: 172.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 172.h),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.email),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  TextField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.password),
                    ),
                  ),
                  SizedBox(height: 96.h),
                  ElevatedButton(
                    onPressed: () {
                      final userBloc = context.read<UserBloc>();
                      if (FirebaseAuth.instance.currentUser != null) {
                        userBloc.add(UserSignOut());
                      }

                      userBloc.add(UserSignInWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                      ));
                    },
                    style: TextButton.styleFrom(
                      elevation: 4,
                    ),
                    child: Text(AppLocalizations.of(context)!.signIn),
                  ),
                ],
              ),
            ),
          ),
          persistentFooterButtons: [
            Center(
              child: FittedBox(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.notRegistered),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.registerHere),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
