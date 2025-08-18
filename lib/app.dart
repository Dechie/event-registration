import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/features/admin_dashboard/presentation/bloc/admin_dashboard_bloc.dart';
import 'package:event_reg/features/attendance_report/presentation/bloc/attendance_report_bloc.dart';
import 'package:event_reg/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:event_reg/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:event_reg/features/event_registration/presentation/bloc/event_registration_bloc.dart';
import 'package:event_reg/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:event_reg/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:event_reg/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes/app_router.dart';
import 'config/themes/app_theme.dart';
import 'injection_container.dart' as di;

class EventRegistrationApp extends StatelessWidget {
  const EventRegistrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
          lazy: false, // Ensure immediate initialization
        ),
        BlocProvider(
          create: (_) => di.sl<SplashBloc>()..add(InitializeApp()),
          lazy: false,
        ),
        // BlocProvider(create: (_) => di.sl<EventRegistrationBloc>()),
        // BlocProvider(create: (_) => di.sl<VerificationBloc>()),
        // BlocProvider(create: (_) => di.sl<AdminDashboardBloc>()),
        // BlocProvider(create: (_) => di.sl<ReportBloc>()),
        // BlocProvider(create: (_) => di.sl<AttendanceReportBloc>()),
      ],
      child: MaterialApp(
        title: "EventHub",
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: RouteNames.splashPage,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
