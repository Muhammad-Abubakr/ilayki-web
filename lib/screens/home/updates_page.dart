import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ilayki/blocs/user/user_bloc.dart';
import 'package:ilayki/blocs/userbase/userbase_cubit.dart';
import 'package:ilayki/screens/chat/chats_page.dart';
import 'package:ilayki/screens/home/notifications_page.dart';
import 'package:ilayki/screens/home/order_requests_screen.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userBloc = context.read<UserBloc>();
    final user =
        context.read<UserbaseCubit>().getUser(userBloc.state.user!.uid);

    return DefaultTabController(
      length: user.role == UserRoles.seller ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            unselectedLabelColor: const Color.fromARGB(255, 236, 201, 171),
            tabs: [
              Tab(
                  text: AppLocalizations.of(context)!.notifications,
                  icon: const Icon(Icons.notifications)),
              if (user.role == UserRoles.seller)
                Tab(
                    text: AppLocalizations.of(context)!.requests,
                    icon: const Icon(Icons.request_page)),
              Tab(
                text: AppLocalizations.of(context)!.chat,
                icon: const Icon(Icons.chat),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const NotificationsPage(),
            if (user.role == UserRoles.seller) const OrderRequestsScreen(),
            const ChatsPage(),
          ],
        ),
      ),
    );
  }
}
