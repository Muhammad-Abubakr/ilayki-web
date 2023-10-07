import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'blocs/authenticate/authenticate_bloc.dart' as auth;
import 'blocs/basket/basket_cubit.dart';
import 'blocs/chat/chat_bloc.dart';
import 'blocs/orders/orders_cubit.dart';
import 'blocs/products/products_bloc.dart';
import 'blocs/requests/requests_cubit.dart';
import 'blocs/userbase/userbase_bloc.dart' as userbase;
import 'blocs/userchat/userchat_cubit.dart';
import 'blocs/wares/wares_cubit.dart';
import 'dashboard.dart';
import 'firebase_options.dart';
import 'pages/loginpage.dart';
import 'pages/registerpage.dart';

void main() {
  (() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      MultiBlocProvider(providers: [
        BlocProvider(
          create: (BuildContext context) =>
              auth.AuthenticateBloc()..add(auth.InitEvent()),
        ),
        BlocProvider(
          create: (BuildContext context) =>
              userbase.UserbaseBloc()..add(userbase.InitEvent()),
        ),
        BlocProvider(
          create: (BuildContext context) => ChatBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => UserchatCubit()..initialize(),
        ),
        BlocProvider(
          create: (BuildContext context) => ProductsBloc()..add(InitEvent()),
        ),
        BlocProvider(
          create: (BuildContext context) => WaresCubit()..initialize(),
        ),
        BlocProvider(
          create: (BuildContext context) =>
              BasketCubit(BlocProvider.of<WaresCubit>(context))..initialize(),
        ),
        BlocProvider(
          create: (BuildContext context) => OrdersCubit()..initialize(),
        ),
        BlocProvider(
          create: (BuildContext context) => RequestsCubit()..initialize(),
        ),
      ], child: const MyApp()),
    );
  })();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Ilayki',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
          textTheme: GoogleFonts.robotoTextTheme(),
          inputDecorationTheme: InputDecorationTheme(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                )),
          ),
          useMaterial3: true,
        ),
        initialRoute: LoginPage.route,
        routes: {
          LoginPage.route: (_) => const LoginPage(),
          RegisterPage.route: (_) => const RegisterPage(),
          Dashboard.route: (_) => const Dashboard(),
        });
  }
}
