import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ItemWidget extends StatefulWidget {
  const ItemWidget({super.key});

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(24.r)),
            color: Theme.of(context).primaryColor,
          ),
          width: 64.spMax,
          height: 64.spMax,
        ),
        Column(
          children: [
            Text(
              "Item Name",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              width: 296.w,
              child: const Text(
                "Item description",
                softWrap: true,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.redAccent,
          onPressed: _deleteItem,
        ),
      ],
    );
  }

  void _deleteItem() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmation Dialog"),
        content: const Text("Do you really want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
