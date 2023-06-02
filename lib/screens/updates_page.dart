import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          bottom: TabBar(
            unselectedLabelColor: const Color.fromARGB(255, 236, 201, 171),
            tabs: [
              Tab(
                  text: AppLocalizations.of(context)!.notifications,
                  icon: const Icon(Icons.notifications)),
              Tab(
                text: AppLocalizations.of(context)!.chat,
                icon: const Icon(Icons.chat),
              ),
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
