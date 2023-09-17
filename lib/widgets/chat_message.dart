import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../blocs/user/user_bloc.dart';
import '../models/message.dart';

class ChatMessage extends StatelessWidget {
  final Message message;

  const ChatMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return Align(
          alignment: message.sender == state.user?.uid
              ? Alignment.topRight
              : Alignment.topLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4.spMax),
            padding: EdgeInsets.all(8.spMax),
            decoration: BoxDecoration(
              boxShadow: kElevationToShadow[3],
              borderRadius: BorderRadius.circular(32.r),
              color: message.sender == state.user?.uid
                  ? Theme.of(context).primaryColor
                  : Colors.white,
            ),
            child: Text(
              message.content,
              textAlign: message.sender == state.user?.uid
                  ? TextAlign.right
                  : TextAlign.left,
              style: TextStyle(
                color: message.sender == state.user?.uid
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
