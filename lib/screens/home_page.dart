import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/cubit/wares_cubit.dart';
import 'package:ilayki/utils/users.dart';
import 'package:ilayki/widgets/item_overview_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/user.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final List<User> users;

  @override
  void initState() {
    /* Await the users */
    (() async {
      users = await getUsers();
    })();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // orientation
    final isLandscape = MediaQuery.of(context).orientation.index == 1;

    return BlocBuilder<WaresCubit, WaresState>(
      builder: (context, state) {
        /* If there are no items in warehouse display text in center */
        return state.wares.isEmpty
            ? Center(
                child: Text(AppLocalizations.of(context)!.nothingToShowHereForTheMoment),
              )
            /* otherwise build items */
            : ListView.separated(
                padding: isLandscape
                    ? EdgeInsets.symmetric(horizontal: 0.25.sw, vertical: 16.spMax)
                    : EdgeInsets.all(10.0.spMax),
                separatorBuilder: (context, _) => const Divider(thickness: 0),
                itemBuilder: (context, index) {
                  /* get the owner of the item from users */
                  final user = users.firstWhere((u) => u.uid == state.wares[index].owner);

                  /* return the Item Overview Widget */
                  return ItemOverview(
                    idx: index,
                    item: state.wares[index],
                    owner: user,
                  );
                },
                itemCount: state.wares.length,
              );
      },
    );
  }
}
