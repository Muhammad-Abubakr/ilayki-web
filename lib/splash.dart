import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ilayki/blocs/userbase/userbase_cubit.dart';
import 'package:ilayki/blocs/wares/wares_cubit.dart';
import 'package:ilayki/screens/auth/login_screen.dart';

import '../blocs/user/user_bloc.dart';
import 'app.dart';
import 'blocs/online/online_cubit.dart';

class SplashScreen extends StatelessWidget {
  // Route Name
  static const routeName = '/splash';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /* Do the initializations (that does not concern
    current user specifically)*/
    context.read<UserbaseCubit>().initialize();
    context.read<WaresCubit>().intialize();
    /* Initialize the online users */
    final onlineCubit = context.read<OnlineCubit>();
    onlineCubit.initialize();
    onlineCubit.setOnline();

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        switch (state.state) {
          case UserStates.signedIn:
            Future.delayed(const Duration(seconds: 3)).then((_) {
              Navigator.of(context).popAndPushNamed(App.routeName);
            });
            break;
          case UserStates.signedOut:
            Future.delayed(const Duration(seconds: 3)).then((_) {
              Navigator.of(context).popAndPushNamed(LoginScreen.routeName);
            });
            break;
          default:
            break;
        }

        return Container(
          height: 1.sh,
          margin: EdgeInsets.symmetric(vertical: 20.h),
          color: Theme.of(context).colorScheme.secondary,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Ilayki",
                style: GoogleFonts.kaushanScript(fontSize: 172.spMax),
              )
            ],
          ),
        );
      },
    );
  }
}
