import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'localization_state.dart';

class LocalizationCubit extends Cubit<LocalizationState> {
  LocalizationCubit() : super(LocalizationInitial(locale: SupportedLocales.ar));

  /* Update Cubit By passing the Supported Locale */
  // we can do things by using the following functionality on changing of cubit state
  // @override
  // void onChange(Change<LocalizationState> change) {
  //   super.onChange(change);
  // }

  /* and handle errors by following */
  // @override
  // void onError(Object error, StackTrace stackTrace) {
  //   super.onError(error, stackTrace);
  // }

  /* Update the locale */
  void updateLocale(SupportedLocales locale) {
    emit(LocalizationUpdate(locale: locale));
  }
}
