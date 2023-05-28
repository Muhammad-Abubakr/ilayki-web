import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ItemWidget extends StatefulWidget {
  final int index;
  const ItemWidget({super.key, required this.index});

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    /* Wrapping in dismissable for deletion */
    return Dismissible(
      direction: DismissDirection.endToStart,
      background: _buildDismissibleBackground(),
      confirmDismiss: _deleteItem,
      key: Key('${widget.index}'),
      child: Padding(
        padding: EdgeInsets.only(right: 8.0.w),
        /* Item */
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /* Item Image */
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
                /* Item Name */
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
                /* Item Description */
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
            /* Price Text */
            const Text('\$99.99'),
          ],
        ),
      ),
      onDismissed: (direction) {
        /* Update the State of Items List which will in turn update this */
      },
    );
  }

  Future<bool?> _deleteItem(DismissDirection direction) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('confirm'),
          ),
        ],
        title: const Text("Confirm Dismissle"),
        content: const Text('Do you really want to remove this item?'),
      ),
    );
  }
}

// Generator Method
Widget _buildDismissibleBackground() {
  return Container(
    padding: EdgeInsets.only(right: 24.spMax),
    alignment: Alignment.centerRight,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24.r),
      color: Colors.redAccent,
    ),
    child: const Icon(Icons.delete_sweep, color: Colors.white),
  );
}
