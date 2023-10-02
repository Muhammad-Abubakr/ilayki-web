import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/email_verificaton/email_verification_cubit.dart';
import 'package:ilayki/blocs/user/user_bloc.dart';
import 'package:ilayki/screens/auth/login_screen.dart';

import '../../app.dart';
import '../../blocs/orders/orders_cubit.dart';
import '../../blocs/requests/requests_cubit.dart';
import '../../blocs/sales/sales_cubit.dart';
import '../../blocs/userchat/userchat_cubit.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = context.read<UserBloc>().state.user;

    return user == null
        ? Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.spMax),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.somethingWentWrong,
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(LoginScreen.routeName),
                    child: Text(AppLocalizations.of(context)!.backToLogin),
                  )
                ],
              ),
            ),
          )
        : BlocConsumer<EmailVerificationCubit, EmailVerificationState>(
            listener: (context, state) {
              switch (state.status) {
                case EmailVerificationStatus.verified:
                  /* Initialize the requests for current user */
                  context.read<RequestsCubit>().initialize();
                  /* Initialize the orders for current user */
                  context.read<OrdersCubit>().initialize();
                  /* Initialize the sales for current user */
                  context.read<SalesCubit>().initialize();
                  /* Initialize the user chats */
                  context.read<UserchatCubit>().intialize();

                  // Pop the progress indicator
                  Navigator.of(context).pop();
                  // and push the screen
                  Navigator.of(context).popAndPushNamed(App.routeName);
                  break;
                default:
                  break;
              }
            },
            builder: (context, state) {
              return WillPopScope(
                onWillPop: () async =>
                    state.status == EmailVerificationStatus.verified,
                child: Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    title: const Text("Email Verification"),
                  ),
                  body: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0.spMax),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.anEmailSentTo} ${AppLocalizations.of(context)!.followLinkAndVerify}",
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 42.h),
                        Text(
                          AppLocalizations.of(context)!.confirmBeforeLogging,
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushReplacementNamed(LoginScreen.routeName),
                            child: Text(AppLocalizations.of(context)!.signIn)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
