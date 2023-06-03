import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ilayki/blocs/basket/basket_cubit.dart';
import 'package:ilayki/blocs/chat/chat_bloc.dart';
import 'package:ilayki/blocs/items/items_bloc.dart';
import 'package:ilayki/blocs/localization/localization_cubit.dart';
import 'package:ilayki/blocs/online/online_cubit.dart';
import 'package:ilayki/blocs/orders/orders_cubit.dart';
import 'package:ilayki/blocs/requests/requests_cubit.dart';
import 'package:ilayki/blocs/sales/sales_cubit.dart';
import 'package:ilayki/blocs/user/user_bloc.dart';
import 'package:ilayki/blocs/userbase/userbase_cubit.dart';
import 'package:ilayki/blocs/userchat/userchat_cubit.dart';
import 'package:ilayki/l10n/l10n.dart';
import 'package:ilayki/screens/chat/chat_room_screen.dart';
import 'package:ilayki/screens/auth/login_screen.dart';
import 'package:ilayki/screens/auth/register_screen.dart';

import './firebase_options.dart';

import 'app.dart';
import 'blocs/wares/wares_cubit.dart';

void main() {
  (() async {
    // Ensure that the flutter bindings have been initialized
    WidgetsFlutterBinding.ensureInitialized();
    // Initializing Firebase Application
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Intializing Flutter App
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<LocalizationCubit>(create: (context) => LocalizationCubit()),
          BlocProvider<UserBloc>(create: (context) => UserBloc()),
          BlocProvider<ItemsBloc>(create: (context) => ItemsBloc()),
          BlocProvider<ChatBloc>(create: (context) => ChatBloc()),
          BlocProvider<WaresCubit>(create: (context) => WaresCubit()),
          BlocProvider<UserbaseCubit>(create: (context) => UserbaseCubit()),
          BlocProvider<OnlineCubit>(create: (context) => OnlineCubit()),
          BlocProvider<ChatBloc>(create: (context) => ChatBloc()),
          BlocProvider<UserchatCubit>(create: (context) => UserchatCubit()),
          BlocProvider<BasketCubit>(create: (context) => BasketCubit()),
          BlocProvider<RequestsCubit>(create: (context) => RequestsCubit()),
          BlocProvider<OrdersCubit>(create: (context) => OrdersCubit()),
          BlocProvider<SalesCubit>(create: (context) => SalesCubit()),
        ],
        child: const MyApp(),
      ),
    );
  })();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Watching the locale state of the application
    final locale = context.watch<LocalizationCubit>().state.locale;

    return MaterialApp(
      title: 'Ilayki',
      // Locales Supported in the Application
      locale: Locale(locale),
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        fontFamily: "KaushanScript",
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 246, 246),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 244, 217, 185)),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromARGB(255, 255, 246, 246),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              width: 2,
              color: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 244, 217, 185))
                  .primary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 244, 217, 185))
                  .primary,
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: ColorScheme.fromSwatch(primarySwatch: Colors.red).primary,
            ),
          ),
        ),
      ),
      // Home (include when Initial Route not given)
      // home: const App(),
      // Initial Route
      initialRoute: LoginScreen.routeName,
      // Root Route Table
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        App.routeName: (_) => const App(),
        ChatRoomScreen.routeName: (_) => const ChatRoomScreen(),
      },
    );
  }
}
