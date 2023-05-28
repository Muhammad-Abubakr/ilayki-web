import 'package:flutter/material.dart';

import 'item_widget.dart';

class UserItems extends StatelessWidget {
  const UserItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        itemBuilder: (_, idx) => const ItemWidget(),
        separatorBuilder: (_, idx) => const Divider(),
        itemCount: 100,
      ),
    );
  }
}
