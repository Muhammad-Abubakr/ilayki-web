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
import 'package:ilayki/widgets/main_drawer.dart';

import 'blocs/basket/basket_cubit.dart';
import 'blocs/items/items_bloc.dart';
import 'blocs/notifications/notifications_cubit.dart';
import 'blocs/orders/orders_cubit.dart';
import 'blocs/sales/sales_cubit.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/userchat/userchat_cubit.dart';
import 'blocs/wares/wares_cubit.dart';
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
  late LocalizationCubit cubit;
  late UserbaseCubit userbaseCubit;
  late SupportedLocales dropdownValue;
  late OnlineCubit onlineCubit;

  /* Hooking the app lifecycles */
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // Localization cubit
    cubit = context.read<LocalizationCubit>();
    userbaseCubit = context.read<UserbaseCubit>();
    /* Initialize the wares */
    context.watch<WaresCubit>().intialize();
    /* Fetch the Items */
    context.read<ItemsBloc>().add(const ActivateItemsListener());
    /* Initialize the online users */
    onlineCubit = context.read<OnlineCubit>();
    onlineCubit.setOnline();
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
    /* Locales Dropdown */
    dropdownValue = SupportedLocales.values.firstWhere(
      (element) => describeEnum(element) == cubit.state.locale,
    );

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Localization cubit
    userbaseCubit.dispose();
    /* Initialize the wares */
    context.read<WaresCubit>().dispose();
    /* Fetch the Items */
    context.read<ItemsBloc>().add(const ActivateItemsListener());
    /* Initialize the online users */
    onlineCubit = context.read<OnlineCubit>();
    onlineCubit.setOffline();
    /* Initialize the requests for current user */
    context.read<RequestsCubit>().dispose();
    /* Initialize the orders for current user */
    context.read<OrdersCubit>().dispose();
    /* Initialize the sales for current user */
    context.read<SalesCubit>().dispose();
    /* Initialize the user chats */
    context.read<UserchatCubit>().dispose();
    /* Initialize the user chats */
    context.read<NotificationsCubit>().dispose();

    super.dispose();
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
      builder: (context, state) => state.user == null ||
              (userbaseCubit.state.seller.isEmpty &&
                  userbaseCubit.state.customer.isEmpty)
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
                  style: GoogleFonts.kaushanScript(),
                ),
                centerTitle: true,
                foregroundColor: const Color.fromARGB(255, 236, 201, 171),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shadowColor: Colors.transparent,
                elevation: 0,

                // Locales
                actions: [
                  /* Dropdown Button for changing the locale for the application */
                  DropdownButton(
                    iconSize: 16.spMax,
                    elevation: 1,
                    value: dropdownValue,
                    padding: EdgeInsets.zero,

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
                        return const Icon(Icons.notifications);
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
              ),
            ),
    );
  }
}
