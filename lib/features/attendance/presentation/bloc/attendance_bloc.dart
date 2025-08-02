import 'package:event_reg/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'attendance_event.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc() : super(AttendanceInitialState());
}
