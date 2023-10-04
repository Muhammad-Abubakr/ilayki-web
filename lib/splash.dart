import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ilayki/blocs/notifications/notifications_cubit.dart';
import 'package:ilayki/screens/auth/login_screen.dart';

import 'app.dart';
import 'blocs/items/items_bloc.dart';
import 'blocs/online/online_cubit.dart';
import 'blocs/orders/orders_cubit.dart';
import 'blocs/requests/requests_cubit.dart';
import 'blocs/sales/sales_cubit.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/userbase/userbase_cubit.dart';
import 'blocs/userchat/userchat_cubit.dart';
import 'blocs/wares/wares_cubit.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late OnlineCubit onlineCubit;

  @override
  void didChangeDependencies() {
    /* Initialize the wares */
    context.read<WaresCubit>().intialize();
    /* Initialize the userbase */
    context.read<UserbaseCubit>().initialize();
    /* Fetch the Items */
    context.read<ItemsBloc>().add(const ActivateItemsListener());
    /* Initialize the online users */
    onlineCubit = context.read<OnlineCubit>();
    onlineCubit.initialize();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        switch (state.state) {
          case UserStates.signedIn:
            onlineCubit.setOnline();
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

            Future.delayed(
              const Duration(seconds: 3),
              () => Navigator.of(context).pushReplacementNamed(App.routeName),
            );
            break;
          case UserStates.signedOut:
            Future.delayed(
              const Duration(seconds: 3),
              () => Navigator.of(context)
                  .pushReplacementNamed(LoginScreen.routeName),
            );
            break;
          default:
            break;
        }
      },
      child: ScreenUtilInit(
        designSize: const Size(1080, 2340),
        minTextAdapt: true,
        splitScreenMode: true,
        //* The following builder method returns the child on which we can use screen utils package
        builder: (context, child) => Scaffold(
          body: Center(
            child: Text(
              "Ilayki",
              style: GoogleFonts.kaushanScript(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 96.spMax),
            ),
          ),
        ),
      ),
    );
  }
}
