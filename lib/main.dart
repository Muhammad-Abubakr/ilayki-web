import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ilayki_web/blocs/chat/chat_bloc.dart';
import 'package:ilayki_web/blocs/products/products_bloc.dart';
import 'package:ilayki_web/blocs/userchat/userchat_cubit.dart';
import 'package:ilayki_web/pages/registerpage.dart';

import 'blocs/authenticate/authenticate_bloc.dart' as auth;
import 'blocs/userbase/userbase_bloc.dart' as userbase;
import 'dashboard.dart';
import 'firebase_options.dart';
import 'pages/loginpage.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0x00618264)),
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
