import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ilayki_web/blocs/userbase/userbase_bloc.dart';
import 'package:ilayki_web/pages/cartpage.dart';
import 'package:ilayki_web/pages/chatspage.dart';
import 'package:ilayki_web/pages/homepage.dart';
import 'package:ilayki_web/pages/orderspage.dart';
import 'package:ilayki_web/pages/profilepage.dart';
import 'package:ilayki_web/pages/requestspage.dart';

import 'blocs/authenticate/authenticate_bloc.dart';
import 'pages/loginpage.dart';

class Dashboard extends StatefulWidget {
  static const route = '/app';
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  /// Interface State
  int selectedRail = 0;
  bool isExtended = false;

  List<Widget> screens = const <Widget>[
    HomePage(),
    ChatsPage(),
    CartPage(),
    RequestsPage(),
    OrdersPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final navigatorState = Navigator.of(context);
    final scaffoldMessengerState = ScaffoldMessenger.of(context);
    final textTheme = Theme.of(context).textTheme;
    final AuthenticateBloc authBloc =
        BlocProvider.of<AuthenticateBloc>(context);
    final UserbaseBloc userbaseBloc = BlocProvider.of<UserbaseBloc>(context);

    return BlocConsumer<AuthenticateBloc, AuthenticateState>(
      listener: (context, state) {
        if (state is AuthReset) {
          navigatorState
              .popUntil((route) => route.settings.name == Dashboard.route);
          navigatorState.popAndPushNamed(LoginPage.route);
        }
      },
      builder: (context, state) {
        if (state is AuthSuccessful) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => setState(() => isExtended = !isExtended),
                icon: const Icon(Icons.menu),
              ),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: FadeInImage.assetNetwork(
                      placeholder: "assets/pfp_placeholder.png",
                      image: "${authBloc.state.user?.photoURL}",
                      fit: BoxFit.contain,
                    ).image,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "${state.user?.displayName}",
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ElevatedButton(
                      onPressed: () => authBloc.add(LogoutEvent()),
                      child: const Text("Log out")),
                )
              ],
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNavigationRail(),
                Expanded(child: screens[selectedRail]),
              ],
            ),
          );
        } else if (state is AuthError || state is DatabaseException) {
          return Scaffold(
            body: Center(
              child: Text(
                "${state.error ?? state.exception}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      extended: isExtended,
      labelType: isExtended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.selected,
      selectedIndex: selectedRail,
      onDestinationSelected: (value) => setState(() {
        selectedRail = value;
      }),
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.email_outlined),
          selectedIcon: Icon(Icons.email),
          label: Text('Messages'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.shopping_cart_outlined),
          selectedIcon: Icon(Icons.shopping_cart),
          label: Text('Cart'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.request_page_outlined),
          selectedIcon: Icon(Icons.request_page),
          label: Text('Requests'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.business_center_outlined),
          selectedIcon: Icon(Icons.business_center),
          label: Text('Orders'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }
}
