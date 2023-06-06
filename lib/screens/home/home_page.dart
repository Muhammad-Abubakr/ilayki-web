import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/user/user_bloc.dart';
import 'package:ilayki/blocs/userbase/userbase_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    users = state.userbase
        .where((element) => element.uid != context.read<UserBloc>().state.user!.uid)
        .toList();

    super.didChangeDependencies();
  }

  /* Function to filter wares */
  void filterWares() {
    setState(() {
      users = state.userbase
          .where(
            (element) =>
                element.name.toLowerCase().contains(
                      _controller.text.trim().toLowerCase(),
                    ) &&
                element.uid != context.read<UserBloc>().state.user!.uid,
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // orientation
    final isLandscape = MediaQuery.of(context).orientation.index == 1;

    return BlocBuilder<UserbaseCubit, UserbaseState>(
      builder: (context, state) {
        /* If there are no items in warehouse display text in center */
        return state.userbase.isEmpty
            ? Center(
                child: Text(AppLocalizations.of(context)!.nothingToShowHereForTheMoment),
              )
            /* otherwise build items */
            : Scaffold(
                appBar: !Navigator.of(context).mounted
                    ? null
                    : AppBar(
                        leading: IconButton.filledTonal(
                          onPressed: filterWares,
                          color: Theme.of(context).primaryColor,
                          icon: const Icon(Icons.search),
                        ),
                        backgroundColor: Colors.transparent,
                        // leadingWidth: 0,
                        title: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.searchHelperText,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.r),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.r),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                body: ListView.separated(
                  padding: isLandscape
                      ? EdgeInsets.symmetric(horizontal: 0.25.sw, vertical: 32.h)
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
