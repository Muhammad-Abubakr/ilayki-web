import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/items/items_bloc.dart';

import '../../models/orderitem.dart';

class OrderRatingsScreen extends StatefulWidget {
  final String owner;
  final List<OrderItem> items;

  const OrderRatingsScreen(
      {super.key, required this.owner, required this.items});

  @override
  State<OrderRatingsScreen> createState() => _OrderRatingsScreenState();
}

class _OrderRatingsScreenState extends State<OrderRatingsScreen> {
  double userRating = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemsBloc, ItemsState>(
      listener: (context, state) {
        switch (state.status) {
          default:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.rating),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /* Silly Prompt */
              Text(
                AppLocalizations.of(context)!.rateYourOrder,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface),
              ),

              /* Spacing */
              SizedBox(
                height: 24.spMax,
              ),

              /* Rating Indicator */
              RatingBar(
                ratingWidget: RatingWidget(
                  empty: Icon(
                    Icons.star_border_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  full: Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  half: Icon(
                    Icons.star_half,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                itemCount: 5,
                unratedColor: Theme.of(context).colorScheme.primary,
                glowColor: Theme.of(context).colorScheme.primary,
                initialRating: userRating,
                allowHalfRating: true,
                updateOnDrag: true,
                glow: true,
                onRatingUpdate: (value) => setState(() => userRating = value),
              ),

              /* Spacing */
              SizedBox(
                height: 96.spMax,
              ),

              /* Submit Rating */
              ElevatedButton(
                onPressed: () {
                  final itemsBloc = context.read<ItemsBloc>();
                  for (OrderItem item in widget.items) {
                    itemsBloc.add(UpdateItemRating(
                        rating: userRating,
                        itemId: item.item.id,
                        ownerUid: item.item.owner));
                  }

                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.confirm),
              )
            ],
          ),
        ),
      ),
    );
  }
}
