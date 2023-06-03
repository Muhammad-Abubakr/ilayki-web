import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'localization_state.dart';

class LocalizationCubit extends Cubit<LocalizationState> {
  LocalizationCubit() : super(LocalizationInitial(locale: SupportedLocales.ar));

  /* Update Cubit By passing the Supported Locale */

  /* Update the locale */
  void updateLocale(SupportedLocales locale) {
    emit(LocalizationUpdate(locale: locale));
  }
}
