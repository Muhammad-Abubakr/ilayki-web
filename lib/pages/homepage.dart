import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ilayki_web/pages/chatroompage.dart';

import '../blocs/userbase/userbase_bloc.dart';
import '../models/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late UserbaseBloc userbaseBloc;
  List<User>? users;
  bool sortAscending = false;
  int columnSortIndex = 0;

  @override
  void didChangeDependencies() {
    userbaseBloc = BlocProvider.of<UserbaseBloc>(context, listen: true);
    users = userbaseBloc.state.users;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (userbaseBloc.state is UserbasePopulate) {
      return Card(
        elevation: 4,
        child: SingleChildScrollView(
          child: DataTable(
            sortAscending: sortAscending,
            sortColumnIndex: columnSortIndex,
            dividerThickness: 1,
            columns: <DataColumn>[
              DataColumn(label: const Text("ID"), onSort: onSort),
              const DataColumn(label: Text("Profile Picture")),
              DataColumn(label: const Text("Name"), onSort: onSort),
              DataColumn(label: const Text("Email"), onSort: onSort),
              const DataColumn(label: Text("Products")),
              const DataColumn(label: Text("Message")),
            ],
            rows: users!
                .map((user) => DataRow(
                      cells: [
                        DataCell(Text(user.uid)),
                        DataCell(
                          CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: CircleAvatar(
                                    backgroundImage: Image.network(user.pfp,
                                            fit: BoxFit.cover)
                                        .image,
                                  ))),
                        ),
                        DataCell(Text(user.displayName)),
                        DataCell(Text(user.email)),
                        DataCell(TextButton(
                          onPressed: () => {},
                          child: Text(
                              "See ${user.displayName.split(' ')[0]}'s products"),
                        )),
                        DataCell(
                          IconButton(
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ChatroomPage(otherUser: user))),
                              icon: const Icon(Icons.chat)),
                        ),
                      ],
                    ))
                .toList(),
          ),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  void onSort(int columnIndex, bool ascending) {
    setState(() {
      columnSortIndex = columnIndex;
      sortAscending = ascending;

      switch (columnIndex) {
        case 0:
          users!.sort((a, b) => a.uid.compareTo(b.uid));
          break;
        case 2:
          users!.sort((a, b) => a.displayName.compareTo(b.displayName));
          break;
        case 3:
          users!.sort((a, b) => a.email.compareTo(b.email));
          break;
      }

      if (!ascending) {
        users = users!.reversed.toList();
      }
    });
  }
}
