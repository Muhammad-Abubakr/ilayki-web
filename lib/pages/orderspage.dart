import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ilayki_web/blocs/orders/orders_cubit.dart';

import '../blocs/userbase/userbase_bloc.dart';
import '../blocs/wares/wares_cubit.dart';
import '../models/order.dart';
import '../models/user.dart';
import 'chatroompage.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late OrdersCubit ordersCubit;
  late WaresCubit waresCubit;
  late UserbaseBloc userbaseBloc;
  late User user;
  List<Order>? orders;

  @override
  void didChangeDependencies() {
    ordersCubit = BlocProvider.of<OrdersCubit>(context, listen: true);
    waresCubit = BlocProvider.of<WaresCubit>(context, listen: true);
    userbaseBloc = BlocProvider.of<UserbaseBloc>(context, listen: false);
    setState(() =>
    orders = ordersCubit.state.orders
    );

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _buildOrderTable();
  }

  Widget _buildOrderTable() {
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
              rows: ordersCubit.state.runtimeType == OrdersPopulate
                  ? orders!.map((order) {
                      final product = waresCubit.getProduct(order.pid);
                      final user = userbaseBloc.getUser(order.ownerUid);

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
                          IconButton(
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ChatroomPage(otherUser: user))),
                              icon: const Icon(Icons.chat)),
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
