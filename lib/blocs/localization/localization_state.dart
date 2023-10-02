part of 'localization_cubit.dart';

enum SupportedLocales { en, fr, ar }

abstract class LocalizationState extends Equatable {
  /* LocalizationState */
  final String locale;

  const LocalizationState({required this.locale});

  /* Deep Equality Check for LocalizationState objects using Equatable  */
  @override
  List<Object> get props => [locale];
}

/* Initial State */
class LocalizationInitial extends LocalizationState {
  LocalizationInitial({required SupportedLocales locale})
      : super(locale: describeEnum(locale));
}

/* Updated State */
class LocalizationUpdate extends LocalizationState {
  LocalizationUpdate({required SupportedLocales locale}) : super(locale: describeEnum(locale));
}
