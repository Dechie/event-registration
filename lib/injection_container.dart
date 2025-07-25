// Updated injection_container.dart to include dashboard dependencies
import 'package:dio/dio.dart';
import 'package:event_reg/features/dashboard/lib/features/dashboard/data/datasource/dashboard_datasource.dart';
import 'package:event_reg/features/dashboard/lib/features/dashboard/data/datasource/dashboard_local_datasource.dart';
import 'package:event_reg/features/dashboard/lib/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:event_reg/features/dashboard/lib/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:event_reg/features/registration/data/datasources/registratoin_local_datasource.dart';
import 'package:event_reg/features/registration/data/repositories/registration_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'features/registration/data/datasources/registration_remote_datasource.dart';
import 'features/registration/presentation/bloc/registration_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // ! Features - Dashboard
  // Bloc
  sl.registerFactory(() => DashboardBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // DataSources
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ! Features - Registration
  // Bloc
  sl.registerFactory(() => RegistrationBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<RegistrationRepository>(
    () => RegistrationRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // DataSources
  sl.registerLazySingleton<RegistrationRemoteDataSource>(
    () => RegistrationRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<RegistrationLocalDataSource>(
    () => RegistrationLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));

  // ! External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  // Shared Preferences
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefs);
}
