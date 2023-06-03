import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ilayki/blocs/online/online_cubit.dart';
import 'package:ilayki/blocs/user/user_bloc.dart';

import '../blocs/items/items_bloc.dart';
import '../blocs/userbase/userbase_cubit.dart';
import '../blocs/wares/wares_cubit.dart';
import '../screens/orders_screen.dart';
import '../screens/sales_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 244, 217, 185),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      width: 0.7.sw,

      /* Adding a Safe Area in order to avoid notches */
      child: SafeArea(
        /* Adding SingleChildScrollView in order to avoid screen cutoffs */
        child: SingleChildScrollView(
          /* Using a column since we have mutiple options in drawer */
          child: Column(
            children: [
              /* Just a header, displaying brand */
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Ilayki",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 196.sp,
                  ),
                ),
              ),
              /* divider to separate header from menu */
              const Divider(thickness: 2, color: Colors.white54),
              /* Menu Items */
              //? Navigate to Order Screen
              ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OrdersScreen(),
                    ),
                  );
                },
                splashColor: Colors.white30,
                leading: Text(
                  AppLocalizations.of(context)!.orders,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 72.sp,
                  ),
                ),
                style: ListTileStyle.drawer,
              ),
              const Divider(thickness: 2, color: Colors.white54),

              // ? Navigate to Sales Screen (keeps record)
              ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SalesScreen(),
                    ),
                  );
                },
                splashColor: Colors.white30,
                leading: Text(
                  AppLocalizations.of(context)!.sales,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 72.sp,
                  ),
                ),
                style: ListTileStyle.drawer,
              ),
              const Divider(thickness: 2, color: Colors.white54),

              // ? Navigate to about us screen
              ListTile(
                onTap: () => {},
                splashColor: Colors.white30,
                leading: Text(
                  AppLocalizations.of(context)!.aboutUs,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 72.sp,
                  ),
                ),
                style: ListTileStyle.drawer,
              ),
              const Divider(thickness: 2, color: Colors.white54),

              // ?  Navigate to Contact Us form
              ListTile(
                onTap: () => {},
                splashColor: Colors.white30,
                leading: Text(
                  AppLocalizations.of(context)!.contactUs,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 72.sp,
                  ),
                ),
                style: ListTileStyle.drawer,
              ),
              Divider(
                thickness: 2,
                color: Colors.white54,
                height: 10.h,
              ),

              // ?  Sign Out
              ListTile(
                onTap: () {
                  /* Clear the App State */
                  ScaffoldMessenger.of(context).clearMaterialBanners();
                  ScaffoldMessenger.of(context).clearSnackBars();

                  /* Dipose of the wares */
                  context.read<WaresCubit>().dispose();

                  /* Dipose of the wares */
                  context.read<OnlineCubit>().dispose();

                  /* Dipose of the userbase */
                  context.read<UserbaseCubit>().dispose();

                  /* This seems like a good point to unsubscribe to items stream */
                  context.read<ItemsBloc>().add(const DeactivateItemsListener());

                  /* Sign Out the User */
                  context.read<UserBloc>().add(UserSignOut());
                },
                splashColor: Colors.white30,
                tileColor: Theme.of(context).primaryColor,
                iconColor: const Color.fromARGB(255, 244, 217, 185),
                leading: const Icon(Icons.logout),
                title: const Text(
                  "Log Out",
                  style: TextStyle(color: Colors.white),
                ),
                style: ListTileStyle.drawer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
