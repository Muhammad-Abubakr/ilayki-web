import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/userbase/userbase_cubit.dart';
import 'package:ilayki/widgets/item_overview_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../blocs/wares/wares_cubit.dart';
import '../../models/item.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // controllers
  final TextEditingController _controller = TextEditingController();

  // wares Cubit
  late WaresState state;
  List<Item> wares = List.empty(growable: true);

  @override
  void didChangeDependencies() {
    // get the wares cubit
    state = context.watch<WaresCubit>().state;

    // update the wares
    wares = state.wares;

    super.didChangeDependencies();
  }

  /* Function to filter wares */
  void filterWares() {
    setState(() {
      wares = state.wares
          .where((element) => element.name.toLowerCase().contains(
                _controller.text.trim().toLowerCase(),
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // orientation
    final isLandscape = MediaQuery.of(context).orientation.index == 1;
    // watching the userbase cubit
    final userbaseCubit = context.watch<UserbaseCubit>();

    return BlocBuilder<WaresCubit, WaresState>(
      builder: (context, state) {
        /* If there are no items in warehouse display text in center */
        return state.wares.isEmpty || userbaseCubit.state.userbase.isEmpty
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
                              hintText: "empty search for all items...",
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
                    /* get the owner of the item from users */
                    final user = userbaseCubit.state.userbase
                        .firstWhere((u) => u.uid == wares[index].owner);

                    /* return the Item Overview Widget */
                    return ItemOverview(
                      idx: index,
                      item: wares[index],
                      owner: user,
                    );
                  },
                  itemCount: wares.length,
                ),
              );
      },
    );
  }
}
