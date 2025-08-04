import 'package:dio/dio.dart';
import 'package:event_reg/core/services/user_data_service.dart';
import 'package:event_reg/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:event_reg/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:event_reg/features/auth/data/datasource/profile_remote_datasource.dart';
// Fix: Import from the correct file
import 'package:event_reg/features/auth/data/repositories/auth_repository.dart';
import 'package:event_reg/features/auth/data/repositories/profile_add_repository.dart';
import 'package:event_reg/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:event_reg/features/dashboard/data/datasource/dashboard_datasource.dart';
import 'package:event_reg/features/dashboard/data/datasource/dashboard_local_datasource.dart';
import 'package:event_reg/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:event_reg/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:event_reg/features/event_registration/data/datasource/event_registration_datasource.dart';
import 'package:event_reg/features/event_registration/presentation/bloc/event_registration_bloc.dart';
import 'package:event_reg/features/registration/data/datasources/registratoin_local_datasource.dart';
import 'package:event_reg/features/registration/data/repositories/registration_repository.dart';
import 'package:event_reg/features/splash/data/datasource/splash_datasource.dart';
import 'package:event_reg/features/splash/data/repositories/splash_repository.dart';
import 'package:event_reg/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'features/registration/data/datasources/registration_remote_datasource.dart';
import 'features/registration/presentation/bloc/registration_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // ! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));

  // ! External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  // Shared Preferences
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefs);

  // ! Services
  sl.registerLazySingleton<UserDataService>(
    () => UserDataServiceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // ! Features - Auth
  // DataSources first (dependencies)
  debugPrint("registering authremotedatasource");
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(dioClient: sl()),
  );
  debugPrint("registering profileremotedatasource");
  sl.registerLazySingleton<ProfileRemoteDatasource>(
    () => ProfileRemoteDatasourceImpl(dioClient: sl()),
  );

  debugPrint("registering authlocaldatasource");
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(
      userDataService: sl<UserDataService>(),
      sharedPrefs: sl<SharedPreferences>(),
    ),
  );

  // Repository (depends on datasources and network)
  debugPrint("registering authrepository");
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      profileRemoteDatasource: sl<ProfileRemoteDatasource>(),
      remoteDatasource: sl<AuthRemoteDatasource>(),
      localDataSource: sl<AuthLocalDatasource>(),
      networkInfo: sl<NetworkInfo>(), // Fix: Add missing NetworkInfo
    ),
  );

  debugPrint("registering authrepository");
  sl.registerLazySingleton<ProfileAddRepository>(
    () => ProfileAddRepositoryImpl(
      profileRemoteDatasource: sl<ProfileRemoteDatasource>(),
    ),
  );

  // Bloc (depends on repository)
  debugPrint("registering authbloc");
  sl.registerFactory(
    () => AuthBloc(
      authRepository: sl(),
      profileRepository: sl(),
      userDataService: sl(),
    ),
  );

  debugPrint("registering event registration datasource");
  sl.registerLazySingleton<EventRegistrationDataSource>(
    () =>
        EventRegistrationDataSourceImpl(dioClient: sl(), userDataService: sl()),
  );

  // ! Features - Splash
  // DataSources
  sl.registerLazySingleton<SplashLocalDataSource>(
    () => SplashLocalDataSourceImpl(userDataService: sl()),
  );

  // Repository
  sl.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(localDataSource: sl()),
  );

  // Bloc
  sl.registerFactory(() => SplashBloc(repository: sl()));

  sl.registerFactory(
    () => EventRegistrationBloc(dataSource: sl(), userDataService: sl()),
  );

  // ! Features - Dashboard
  // DataSources
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Bloc
  sl.registerFactory(() => DashboardBloc(repository: sl()));

  // ! Features - Registration
  // DataSources
  sl.registerLazySingleton<RegistrationRemoteDataSource>(
    () => RegistrationRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<RegistrationLocalDataSource>(
    () => RegistrationLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<RegistrationRepository>(
    () => RegistrationRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Bloc
  sl.registerFactory(() => RegistrationBloc(repository: sl()));
}
