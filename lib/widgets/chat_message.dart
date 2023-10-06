import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/authenticate/authenticate_bloc.dart';
import '../models/message.dart';

class ChatMessage extends StatelessWidget {
  final Message message;

  const ChatMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticateBloc, AuthenticateState>(
      builder: (context, state) {
        return Align(
          alignment:
              message.senderUid == state.user?.uid ? Alignment.topRight : Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              boxShadow: kElevationToShadow[3],
              borderRadius: BorderRadius.circular(12),
              color: message.senderUid == state.user?.uid
                  ? Theme.of(context).primaryColor
                  : Colors.white,
            ),
            child: Text(
              message.content,
              textAlign:
                  message.senderUid == state.user?.uid ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontSize: 18,
                color: message.senderUid == state.user?.uid
                    ? Colors.white
                    : Theme.of(context).primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
