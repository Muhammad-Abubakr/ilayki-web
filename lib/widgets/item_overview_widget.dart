import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/basket/basket_cubit.dart';
import 'package:ilayki/blocs/online/online_cubit.dart';

import '../models/item.dart';
import '../models/user.dart';

class ItemOverview extends StatelessWidget {
  final Item item;
  final User owner;
  final int idx;

  const ItemOverview(
      {super.key, required this.idx, required this.item, required this.owner});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          /* Image for the item */
          LayoutBuilder(
            builder: (_, constraints) => FittedBox(
              fit: BoxFit.contain,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  width: constraints.maxWidth,
                  height: 480.h,
                ),
              ),
            ),
          ),
          /* Item and Owner Details */
          ListTile(
            // user pfp
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 64.r,
                  backgroundImage: Image.network(owner.photoURL).image,
                ),
                BlocBuilder<OnlineCubit, OnlineState>(
                  builder: (context, state) {
                    return CircleAvatar(
                      radius: 20.r,
                      backgroundColor: state.onlineUsers.contains(owner.uid)
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    );
                  },
                ),
              ],
            ),

            // item name as title
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16.spMax,
                      color: Theme.of(context).primaryColor,
                    ),
                    Text(
                      "${item.rating ?? AppLocalizations.of(context)!.noRating} (${item.ratingCount})",
                      style: TextStyle(
                        fontSize: 14.spMax,
                      ),
                    )
                  ],
                )
              ],
            ),

            // item price as subtitle
            subtitle: Text(
                '${AppLocalizations.of(context)!.price}: ${item.price} \n ${item.description}'),

            // add to basket button
            trailing: IconButton.filledTonal(
              onPressed: () {
                // add the item to basket
                context.read<BasketCubit>().addItem(item);

                // show basket added snackbar
                ScaffoldMessenger.of(context).clearSnackBars();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    content: Text(
                      '${item.name} ${AppLocalizations.of(context)!.addedToBasket}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_basket_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
