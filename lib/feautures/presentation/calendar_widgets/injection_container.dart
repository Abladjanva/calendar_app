import 'package:calendar_app/data/get_current_date.dart';
import 'package:calendar_app/data/parse_date.dart';
import 'package:calendar_app/data/validate_data_format.dart';
import 'package:calendar_app/feautures/data/repository_impl/calendar_repository.dart';
import 'package:calendar_app/feautures/domain/repository/calendar_repository.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => ValidateDateFormat(sl()));
  sl.registerLazySingleton(() => ParseDate(sl()));
  sl.registerLazySingleton(() => GetCurrentDate(sl()));

  sl.registerLazySingleton<CalendarRepository>(() => CalendarRepositoryImpl());
}
