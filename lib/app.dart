import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ilayki/blocs/localization/localization_cubit.dart';
import 'package:ilayki/blocs/online/online_cubit.dart';
import 'package:ilayki/blocs/requests/requests_cubit.dart';
import 'package:ilayki/blocs/userbase/userbase_cubit.dart';
import 'package:ilayki/screens/auth/login_screen.dart';
import 'package:ilayki/screens/search_screen.dart';
import 'package:ilayki/widgets/main_drawer.dart';

import 'blocs/basket/basket_cubit.dart';
import 'blocs/user/user_bloc.dart';
import 'screens/home/basket_page.dart';
import 'screens/home/home_page.dart';
import 'screens/home/profile_page.dart';
import 'screens/home/updates_page.dart';

class App extends StatefulWidget {
  // route name
  static const routeName = '/app';

  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  /* Blocs */
  late UserbaseCubit userbaseCubit;

  /* Hooking the app lifecyles */
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  /* ----------------------------------- */
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        context.read<OnlineCubit>().setOffline();
        break;

      case AppLifecycleState.resumed:
        /* resume the online status */
        context.read<OnlineCubit>().setOnline();
        break;

      default:
        break;
    }

    super.didChangeAppLifecycleState(state);
  }

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
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        // In case of error
        switch (state.state) {
          case UserStates.signedOut:
            // pop the app
            Navigator.of(context).popAndPushNamed(LoginScreen.routeName);
            break;

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
          default:
            break;
        }
      },
      builder: (context, state) => state.user == null
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Scaffold(
              /* App Bar */
              appBar: AppBar(
                title: Text(
                  "Ilayki",
                  style: GoogleFonts.kaushanScript(fontSize: 32.spMax),
                ),
                centerTitle: true,
                foregroundColor: const Color.fromARGB(255, 236, 201, 171),
                shadowColor: Colors.transparent,
                elevation: 0,

                // Locales
                actions: [
                  /* Dropdown Button for changing the locale for the application */
                  IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const SearchScreen())),
                    color: Theme.of(context).primaryColor,
                    icon: const Icon(Icons.search),
                  ),
                  SizedBox(width: 32.spMax),
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
              body: Row(
                children: [
                  if (MediaQuery.of(context).orientation ==
                      Orientation.landscape)
                    NavigationRail(
                      selectedIndex: currentScreenIndex,
                      useIndicator: true,
                      labelType: NavigationRailLabelType.selected,
                      unselectedIconTheme: const IconThemeData(
                          color: Color.fromARGB(255, 236, 201, 171)),
                      selectedIconTheme: IconThemeData(
                          color: Theme.of(context).colorScheme.primary),
                      onDestinationSelected: (index) =>
                          setState(() => currentScreenIndex = index),
                      destinations: <NavigationRailDestination>[
                        NavigationRailDestination(
                          label: Text(AppLocalizations.of(context)!.home),
                          icon: const Icon(Icons.cookie),
                        ),
                        NavigationRailDestination(
                          label: Text(AppLocalizations.of(context)!.updates),
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
                        NavigationRailDestination(
                          label: Text(AppLocalizations.of(context)!.basket),
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
                        if (userbaseCubit.getUser(state.user!.uid).role !=
                            UserRoles.customer)
                          NavigationRailDestination(
                            label: Text(AppLocalizations.of(context)!.profile),
                            icon: const Icon(Icons.person),
                          ),
                      ],
                    ),
                  Expanded(child: screens[currentScreenIndex]),
                ],
              ),

              /* Bottom Navbar */
              bottomNavigationBar: MediaQuery.of(context).orientation ==
                      Orientation.portrait
                  ? BottomNavigationBar(
                      currentIndex: currentScreenIndex,
                      onTap: (index) =>
                          setState(() => currentScreenIndex = index),
                      unselectedItemColor:
                          const Color.fromARGB(255, 236, 201, 171),
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
                        if (userbaseCubit.getUser(state.user!.uid).role !=
                            UserRoles.customer)
                          BottomNavigationBarItem(
                            label: AppLocalizations.of(context)!.profile,
                            icon: const Icon(Icons.person),
                          ),
                      ],
                    )
                  : null,
            ),
    );
  }
}
