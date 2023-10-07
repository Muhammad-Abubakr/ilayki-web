import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ilayki_web/blocs/basket/basket_cubit.dart';

import '../blocs/wares/wares_cubit.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late BasketCubit basketCubit;
  late WaresCubit waresCubit;

  @override
  void didChangeDependencies() {
    basketCubit = BlocProvider.of<BasketCubit>(context);
    waresCubit = BlocProvider.of<WaresCubit>(context);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final BasketCubit basketCubit = BlocProvider.of<BasketCubit>(context);
    final navigatorState = Navigator.of(context);
    final scaffoldMessengerState = ScaffoldMessenger.of(context);

    return BlocConsumer<BasketCubit, BasketState>(
      builder: (context, state) {
        if (state is BasketInit ||
            state is BasketReset ||
            state is BasketOrderPlaced) {
          return const Center(
            child: Text("Products added to Cart will be shown here."),
          );
        } else {
          return Scaffold(
            body: _buildOrderTable(basketCubit, state),

            /// Order Placement
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => basketCubit.placeOrder(),
              icon: const Icon(Icons.shopping_cart_checkout),
              label: Row(
                children: [
                  Text("Total: ${state.totalValue}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 64),
                  const Text("Place Order",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        }
      },
      listener: (context, state) {
        switch (state.runtimeType) {
          case BasketProcessing:
            navigatorState.push(DialogRoute(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: CircularProgressIndicator(),
              ),
            ));
            break;
          case BasketError:
            navigatorState.pop();
            scaffoldMessengerState.showSnackBar(SnackBar(
              content: Text(
                "${state.exception}",
                textAlign: TextAlign.center,
              ),
            ));
            break;
          case BasketOrderPlaced:
            navigatorState.pop();
            scaffoldMessengerState.showSnackBar(const SnackBar(
              content: Text(
                "Your order has been placed successfully",
                textAlign: TextAlign.center,
              ),
            ));
            break;
        }
      },
    );
  }

  Widget _buildOrderTable(BasketCubit basketCubit, BasketState state) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Card(
            elevation: 4,
            child: DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              dataRowMinHeight: 100,
              dataRowMaxHeight: 100,
              dividerThickness: 1,
              columns: const <DataColumn>[
                DataColumn(label: Text("ID")),
                DataColumn(label: Text("Owner ID")),
                DataColumn(label: Text("Product Picture")),
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Price")),
                DataColumn(label: Text("Quantity")),
                DataColumn(label: Text("Actions")),
              ],
              rows: basketCubit.state.runtimeType == BasketUpdate
                  ? state.purchase!.map((order) {
                      final product = waresCubit.getProduct(order.pid);

                      return DataRow(cells: [
                        DataCell(Text(order.pid)),
                        DataCell(Text(order.ownerUid)),
                        DataCell(
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(product.productImage,
                                    fit: BoxFit.cover)),
                          ),
                        ),
                        DataCell(Text(product.name)),
                        DataCell(Text(product.price.toString())),
                        DataCell(Text(order.quantity.toString())),
                        DataCell(
                          Row(
                            children: [
                              IconButton.filledTonal(
                                onPressed: () =>
                                    basketCubit.decreaseQuantity(product.pid),
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  size: 16,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Text(order.quantity.toString(),
                                    style: const TextStyle(fontSize: 16)),
                              ),
                              IconButton.filledTonal(
                                onPressed: () =>
                                    basketCubit.addToBasket(product),
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList()
                  : const <DataRow>[],
            ),
          ),
        ),
      ),
    );
  }
}
