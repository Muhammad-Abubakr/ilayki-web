import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/userbase/userbase_cubit.dart';
import 'package:ilayki/models/order.dart';
import 'package:ilayki/models/orderitem.dart';

import '../../blocs/basket/basket_cubit.dart';

class BasketPage extends StatefulWidget {
  const BasketPage({super.key});

  @override
  State<BasketPage> createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  TimeOfDay? pickedTime;
  DateTime? pickedDate;
  OrderType orderType = OrderType.delivery;

  @override
  Widget build(BuildContext context) {
    // basket cubit
    final BasketCubit basketCubit = context.watch<BasketCubit>();
    final List<OrderItem> orders = basketCubit.state.orderItems;

    // userbase cubit
    final UserbaseCubit userbaseCubit = context.watch<UserbaseCubit>();

    // orientation
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return basketCubit.state.orderItems.isEmpty
        ? Center(
            child: Text(
                AppLocalizations.of(context)!.nothingToShowHereForTheMoment),
          )
        : Scaffold(
            appBar: isLandscape
                ? null
                : AppBar(
                    title: Text(AppLocalizations.of(context)!.basket),
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(450.h),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 64.sp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.delivery_dining,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    Text(
                                      "${AppLocalizations.of(context)!.orderType} *",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.spMax),
                                    )
                                  ],
                                ),
                                DropdownButton(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.spMax),
                                  value: orderType,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => orderType = value);
                                    }
                                  },
                                  items: OrderType.values
                                      .map((e) => DropdownMenuItem(
                                          alignment: Alignment.center,
                                          value: e,
                                          child: Text(describeEnum(e))))
                                      .toList(),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 32.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_filled,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    Text(
                                      "${AppLocalizations.of(context)!.orderTime} * ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.spMax),
                                    )
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (_) => TimePickerDialog(
                                        initialTime: TimeOfDay.now()),
                                  ).then((value) =>
                                      setState(() => pickedTime = value)),
                                  child: Text(
                                    pickedTime != null
                                        ? "${pickedTime!.hour < 1 ? "00" : pickedTime!.hour}:${pickedTime?.minute} ${describeEnum(pickedTime!.period)}"
                                        : AppLocalizations.of(context)!
                                            .pickATime,
                                    textDirection: TextDirection.ltr,
                                    style: pickedTime != null
                                        ? const TextStyle(
                                            fontWeight: FontWeight.bold)
                                        : null,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 32.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.date_range,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    Text(
                                      "${AppLocalizations.of(context)!.orderDate} * ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.spMax),
                                    )
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (_) => DatePickerDialog(
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2023, 1),
                                      lastDate: DateTime(2023, 12),
                                    ),
                                  ).then((value) =>
                                      setState(() => pickedDate = value)),
                                  child: Text(
                                    pickedDate != null
                                        ? pickedDate.toString().split(" ")[0]
                                        : AppLocalizations.of(context)!
                                            .pickADate,
                                    style: pickedDate != null
                                        ? const TextStyle(
                                            fontWeight: FontWeight.bold)
                                        : null,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            body: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 32.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* Header */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.basketItems),
                      Text(AppLocalizations.of(context)!.quantity),
                      Text(AppLocalizations.of(context)!.singlePrice),
                    ],
                  ),
                  const Divider(),

                  /* Items */
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      itemBuilder: (context, index) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /* Item Image */
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24.r)),
                              color: Theme.of(context).primaryColor,
                              image: DecorationImage(
                                image: Image.network(orders[index].item.image)
                                    .image,
                                fit: BoxFit.cover,
                              ),
                            ),
                            width: 64.spMax,
                            height: 64.spMax,
                          ),
                          /* Item Quantity */
                          Column(
                            children: [
                              /* Add Item */
                              IconButton.filledTonal(
                                onPressed: () =>
                                    basketCubit.addItem(orders[index].item),
                                style: ButtonStyle(
                                  alignment: Alignment.center,
                                  padding: const MaterialStatePropertyAll(
                                      EdgeInsets.all(0)),
                                  fixedSize: MaterialStatePropertyAll(
                                      Size.fromRadius(36.r)),
                                  minimumSize: MaterialStatePropertyAll(
                                      Size.fromRadius(0.r)),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_up_rounded,
                                ),
                              ),

                              /* Quantity display */
                              Text(orders[index].quantity.toString()),

                              /* Remove Item */
                              IconButton.filledTonal(
                                onPressed: () =>
                                    basketCubit.removeItem(orders[index].item),
                                style: ButtonStyle(
                                  alignment: Alignment.center,
                                  padding: const MaterialStatePropertyAll(
                                      EdgeInsets.all(0)),
                                  fixedSize: MaterialStatePropertyAll(
                                      Size.fromRadius(36.r)),
                                  minimumSize: MaterialStatePropertyAll(
                                      Size.fromRadius(0.r)),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_down_rounded,
                                ),
                              ),
                            ],
                          ),
                          /* Price Text */
                          Text('${orders[index].item.price}'),
                        ],
                      ),
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: basketCubit.state.orderItems.length,
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(64.r),
                color: Theme.of(context).primaryColor,
                boxShadow: kElevationToShadow[3],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.total} : ${basketCubit.state.totalPrice.toString()}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Colors.grey.shade800,
                      disabledForegroundColor: Colors.grey.shade600,
                    ),
                    onPressed: pickedTime == null || pickedDate == null
                        ? null
                        : () {
                            // place the order
                            basketCubit.placeOrder(
                                userbaseCubit.getUser(orders.first.item.owner),
                                pickedTime!,
                                orderType,
                                pickedDate!);

                            // show the user that the request has been made to the sellers
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(
                                    AppLocalizations.of(context)!.requestSent),
                                content: Text(AppLocalizations.of(context)!
                                    .requestSentContent),
                              ),
                            );
                          },
                    child: pickedTime == null || pickedDate == null
                        ? const Text("Disabled")
                        : Text(AppLocalizations.of(context)!.placeOrder),
                  )
                ],
              ),
            ),
          );
  }
}
