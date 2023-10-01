import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/userbase/userbase_cubit.dart';

import '../../models/user.dart';
import '../../widgets/user_overview_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // controllers
  final TextEditingController _controller = TextEditingController();

  // Userbase Cubit State
  late UserbaseState state;
  List<User> users = List.empty(growable: true);

  @override
  void didChangeDependencies() {
    // get the wares cubit
    state = context.watch<UserbaseCubit>().state;

    // update the wares
    if (state.seller != null) {
      users = state.seller!;
    }
    super.didChangeDependencies();
  }

  /* Function to filter wares */
  void filterWares() {
    if (state.seller != null) {
      setState(() {
        users = state.seller!
            .where((element) => element.name.toLowerCase().contains(
                  _controller.text.trim().toLowerCase(),
                ))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // orientation
    final isLandscape = MediaQuery.of(context).orientation.index == 1;

    return BlocBuilder<UserbaseCubit, UserbaseState>(
      builder: (context, state) {
        /* If there are no items in warehouse display text in center */
        return state.seller == null || state.seller!.isEmpty
            ? Center(
                child: Text(AppLocalizations.of(context)!
                    .nothingToShowHereForTheMoment),
              )
            /* otherwise build items */
            : Scaffold(
                body: ListView.separated(
                  padding: isLandscape
                      ? EdgeInsets.symmetric(
                          horizontal: 0.25.sw, vertical: 32.h)
                      : EdgeInsets.all(32.h),
                  separatorBuilder: (context, _) => const Divider(thickness: 0),
                  itemBuilder: (context, index) {
                    /* return the Item Overview Widget */
                    return UserOverview(
                      user: users[index],
                    );
                  },
                  itemCount: users.length,
                ),
              );
      },
    );
  }
}
