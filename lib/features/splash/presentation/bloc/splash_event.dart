part of 'splash_bloc.dart';

abstract class SplashEvent {}

class InitializeApp extends SplashEvent {}

class CheckAuthenticationStatus extends SplashEvent {}

class Authenticated extends SplashEvent {}
