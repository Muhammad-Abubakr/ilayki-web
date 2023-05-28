import 'package:flutter/material.dart';
import 'package:ilayki/screens/chats_page.dart';
import 'package:ilayki/screens/notifications_page.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            unselectedLabelColor: Color.fromARGB(255, 236, 201, 171),
            tabs: [
              Tab(text: "Alerts", icon: Icon(Icons.notifications)),
              Tab(text: "Chat", icon: Icon(Icons.chat)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NotificationsPage(),
            ChatsPage(),
          ],
        ),
      ),
    );
  }
}
