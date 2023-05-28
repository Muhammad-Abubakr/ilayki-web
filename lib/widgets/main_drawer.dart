import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../screens/orders_screen.dart';
import '../screens/sales_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 244, 217, 185),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      width: 0.7.sw,

      /* Adding a Safe Area in order to avoid notches */
      child: SafeArea(
        /* Adding SingleChildScrollView in order to avoid screen cutoffs */
        child: SingleChildScrollView(
          /* Using a column since we have mutiple options in drawer */
          child: Column(
            children: [
              /* Just a header, displaying brand */
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Ilayki",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 196.sp,
                  ),
                ),
              ),
              /* divider to separate header from menu */
              const Divider(thickness: 2, color: Colors.white54),
              /* Menu Items */
              //? Navigate to Order Screen
              ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OrdersScreen(),
                  ),
                ),
                splashColor: Colors.white30,
                leading: Text(
                  "Orders",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 72.sp,
                  ),
                ),
                style: ListTileStyle.drawer,
              ),
              const Divider(thickness: 2, color: Colors.white54),

              // ? Navigate to Sales Screen (keeps record)
              ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SalesScreen(),
                  ),
                ),
                splashColor: Colors.white30,
                leading: Text(
                  "Sales",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 72.sp,
                  ),
                ),
                style: ListTileStyle.drawer,
              ),
              const Divider(thickness: 2, color: Colors.white54),

              // ? Navigate to about us screen
              ListTile(
                onTap: () => {},
                splashColor: Colors.white30,
                leading: Text(
                  "About US",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 72.sp,
                  ),
                ),
                style: ListTileStyle.drawer,
              ),
              const Divider(thickness: 2, color: Colors.white54),

              // ?  Navigate to Contact Us form
              ListTile(
                onTap: () => {},
                splashColor: Colors.white30,
                leading: Text(
                  "Contact US",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 72.sp,
                  ),
                ),
                style: ListTileStyle.drawer,
              ),
              const Divider(thickness: 2, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
