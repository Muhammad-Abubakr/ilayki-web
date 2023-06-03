import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/localization/localization_cubit.dart';
import 'package:ilayki/blocs/requests/requests_cubit.dart';
import 'package:ilayki/screens/auth/login_screen.dart';
import 'package:ilayki/widgets/main_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'blocs/basket/basket_cubit.dart';
import 'screens/home/basket_page.dart';
import 'screens/home/home_page.dart';
import 'screens/home/profile_page.dart';
import 'screens/home/updates_page.dart';
import 'blocs/user/user_bloc.dart';

class App extends StatefulWidget {
  // route name
  static const routeName = '/';

  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /* Defining currentIndex as state of the app */
  int currentScreenIndex = 0;

  /* Defining the screens for the app*/
  final List<Widget> screens = [
    const MyHomePage(),
    const UpdatesPage(),
    const BasketPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Localization cubit
    final LocalizationCubit cubit = context.watch<LocalizationCubit>();

    /* Locales Dropdown */
    final SupportedLocales dropdownValue = SupportedLocales.values.firstWhere(
      (element) => describeEnum(element) == cubit.state.locale,
    );

    //* Initializing Screen Utils Package and providing width and height of
    return WillPopScope(
      onWillPop: () async =>
          context.watch<UserBloc>().state.state == UserStates.signedOut ? true : false,
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          // In case of error
          switch (state.state) {
            case UserStates.updated:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.updationSuccessfull,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
              break;
            case UserStates.signedOut:
              Navigator.of(context).popUntil(ModalRoute.withName(LoginScreen.routeName));
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
            /* App Bar */
            appBar: AppBar(
              title: const Text("Ilayki"),
              centerTitle: true,
              foregroundColor: const Color.fromARGB(255, 236, 201, 171),
              shadowColor: const Color.fromARGB(255, 244, 217, 185),
              elevation: 0,

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
                      value: SupportedLocales.en,
                      child: Image.asset(
                        'lib/assets/flags/us.png',
                        fit: BoxFit.scaleDown,
                        height: 16.spMax,
                      ),
                    ),
                    DropdownMenuItem(
                      value: SupportedLocales.ar,
                      child: Image.asset(
                        'lib/assets/flags/sa.png',
                        fit: BoxFit.scaleDown,
                        height: 16.spMax,
                      ),
                    ),
                    DropdownMenuItem(
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

            /* Drawer */
            drawer: const MainDrawer(),

            /* Body */
            body: screens[currentScreenIndex],

            /* Bottom Navbar */
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentScreenIndex,
              onTap: (index) => setState(() => currentScreenIndex = index),
              unselectedItemColor: const Color.fromARGB(255, 236, 201, 171),
              selectedItemColor: Theme.of(context).colorScheme.primary,
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  label: AppLocalizations.of(context)!.home,
                  icon: const Icon(Icons.cookie),
                ),
                BottomNavigationBarItem(
                  label: AppLocalizations.of(context)!.updates,
                  icon: BlocBuilder<RequestsCubit, RequestsState>(
                    builder: (context, state) {
                      return Stack(children: [
                        const Icon(Icons.notifications),
                        if (state.requests.isNotEmpty)
                          CircleAvatar(
                            radius: 12.r,
                            backgroundColor: Colors.red.shade400,
                          ),
                      ]);
                    },
                  ),
                ),
                BottomNavigationBarItem(
                  label: AppLocalizations.of(context)!.basket,
                  icon: BlocBuilder<BasketCubit, BasketState>(
                    builder: (context, state) {
                      return Stack(children: [
                        const Icon(Icons.shopping_basket),
                        if (state.orderItems.isNotEmpty)
                          CircleAvatar(
                            radius: 12.r,
                            backgroundColor: Colors.red.shade400,
                          ),
                      ]);
                    },
                  ),
                ),
                BottomNavigationBarItem(
                  label: AppLocalizations.of(context)!.profile,
                  icon: const Icon(Icons.person),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
