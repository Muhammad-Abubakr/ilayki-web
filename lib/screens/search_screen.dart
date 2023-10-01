import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/wares/wares_cubit.dart';
import 'package:ilayki/models/item.dart';
import 'package:ilayki/widgets/item_widget.dart';

import '../blocs/localization/localization_cubit.dart';
import '../blocs/userbase/userbase_cubit.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // controllers
  final TextEditingController _controller = TextEditingController();

  // Userbase Cubit State
  late WaresState state;
  List<Item> items = List.empty(growable: true);

  @override
  void didChangeDependencies() {
    // get the wares cubit
    state = context.watch<WaresCubit>().state;

    // update the wares
    if (state.wares.isNotEmpty) {
      items = state.wares;
    }
    super.didChangeDependencies();
  }

  /* Function to filter wares */
  void filterWares() {
    setState(() {
      items = state.wares
          .where(
            (element) => element.name.toLowerCase().contains(
                  _controller.text.trim().toLowerCase(),
                ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // orientation
    final isLandscape = MediaQuery.of(context).orientation.index == 1;

    // Localization cubit
    final LocalizationCubit cubit = context.watch<LocalizationCubit>();

    /* Locales Dropdown */
    final SupportedLocales dropdownValue = SupportedLocales.values.firstWhere(
      (element) => describeEnum(element) == cubit.state.locale,
    );

    return BlocBuilder<UserbaseCubit, UserbaseState>(
      builder: (context, state) {
        /* If there are no items in warehouse display text in center */
        return Scaffold(
          appBar: AppBar(
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.r),
                    borderSide: BorderSide(
                      width: 1,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),

            actions: [
              /* Dropdown Button for changing the locale for the application */

              DropdownButton(
                iconSize: 32.spMax,
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
                      height: 32.spMax,
                    ),
                  ),
                  DropdownMenuItem(
                    value: SupportedLocales.ar,
                    child: Image.asset(
                      'lib/assets/flags/sa.png',
                      fit: BoxFit.scaleDown,
                      height: 32.spMax,
                    ),
                  ),
                  DropdownMenuItem(
                    value: SupportedLocales.fr,
                    child: Image.asset(
                      'lib/assets/flags/fr.png',
                      fit: BoxFit.scaleDown,
                      height: 32.spMax,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: items.isEmpty
              ? Center(
                  child: Text(AppLocalizations.of(context)!.nothingToShowHereForTheMoment),
                )
              /* otherwise build items */
              : ListView.separated(
                  padding: isLandscape
                      ? EdgeInsets.symmetric(horizontal: 0.25.sw, vertical: 32.h)
                      : EdgeInsets.all(32.h),
                  separatorBuilder: (context, _) => const Divider(thickness: 0),
                  itemBuilder: (context, index) {
                    /* return the Item Overview Widget */
                    return ItemWidget(
                      item: items[index],
                    );
                  },
                  itemCount: items.length,
                ),
        );
      },
    );
  }
}
