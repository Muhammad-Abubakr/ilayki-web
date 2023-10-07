import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ilayki_web/blocs/userbase/userbase_bloc.dart';
import 'package:ilayki_web/blocs/wares/wares_cubit.dart';
import 'package:ilayki_web/models/user.dart';
import 'package:ilayki_web/pages/chatroompage.dart';

import '../blocs/basket/basket_cubit.dart';
import '../models/product.dart';

class ProductsPage extends StatefulWidget {
  final String uid;

  const ProductsPage({super.key, required this.uid});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool sortAscending = false;
  int columnSortIndex = 0;

  late WaresCubit waresCubit;
  late UserbaseBloc userbaseBloc;
  late BasketCubit basketCubit;
  List<Product>? products;
  late User user;

  @override
  void didChangeDependencies() {
    userbaseBloc = BlocProvider.of<UserbaseBloc>(context, listen: false);
    user = userbaseBloc.getUser(widget.uid);
    waresCubit = BlocProvider.of<WaresCubit>(context, listen: true);
    products = waresCubit.getProductsForUser(user.uid);
    basketCubit = BlocProvider.of<BasketCubit>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _buildProductTable();
  }

  Widget _buildProductTable() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${user.displayName}'s Products",
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ChatroomPage(otherUser: user))),
                icon: const Icon(Icons.chat)),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Card(
            elevation: 4,
            child: DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              sortAscending: sortAscending,
              sortColumnIndex: columnSortIndex,
              dataRowMinHeight: 100,
              dataRowMaxHeight: 100,
              dividerThickness: 1,
              columns: <DataColumn>[
                DataColumn(label: const Text("ID"), onSort: onSort),
                const DataColumn(label: Text("Product Picture")),
                DataColumn(label: const Text("Name"), onSort: onSort),
                DataColumn(label: const Text("Price"), onSort: onSort),
                DataColumn(label: const Text("Stock"), onSort: onSort),
                const DataColumn(label: Text("Actions")),
              ],
              rows: waresCubit.state.runtimeType == WaresPopulate
                  ? products!
                      .map((product) => DataRow(cells: [
                            DataCell(Text(product.pid)),
                            DataCell(
                              Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.all(4),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
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
                            DataCell(Text(product.quantity.toString())),
                            DataCell(
                              IconButton(
                                  onPressed: () =>
                                      basketCubit.addToBasket(product),
                                  icon: const Icon(
                                      Icons.add_shopping_cart_outlined)),
                            ),
                          ]))
                      .toList()
                  : const <DataRow>[],
            ),
          ),
        ),
      ),
    );
  }

  void onSort(int columnIndex, bool ascending) {
    setState(() {
      columnSortIndex = columnIndex;
      sortAscending = ascending;

      switch (columnIndex) {
        case 0:
          products!.sort((a, b) => a.pid.compareTo(b.pid));
          break;
        case 2:
          products!.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 3:
          products!.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 4:
          products!.sort((a, b) => a.quantity.compareTo(b.quantity));
          break;
      }

      if (!ascending) {
        products = products!.reversed.toList();
      }
    });
  }
}
