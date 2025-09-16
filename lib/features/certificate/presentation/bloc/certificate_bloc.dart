import 'package:event_reg/features/certificate/presentation/bloc/certificate_event.dart';
import 'package:event_reg/features/certificate/presentation/bloc/certificate_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_reg/features/certificate/data/repositories/certificate_repository.dart';
import 'package:flutter/material.dart' show debugPrint;

class CertificateBloc extends Bloc<CertificateEvent, CertificateState> {
  final CertificateRepository repository;

  CertificateBloc({required this.repository}) : super(const CertificateInitial()) {
    on<FetchCertificateRequested>(_onFetchCertificate);
    on<FetchMyCertificatesRequested>(_onFetchMyCertificates);
    on<RefreshCertificatesRequested>(_onRefreshCertificates);
  }

  Future<void> _onFetchCertificate(
    FetchCertificateRequested event,
    Emitter<CertificateState> emit,
  ) async {
    emit(const CertificateLoading());
    
    try {
      debugPrint('📋 BLoC: Fetching certificate for badge: ${event.badgeNumber}');
      
      final result = await repository.getCertificate(event.badgeNumber);
      
      result.fold(
        (failure) {
          debugPrint('❌ BLoC: Failed to fetch certificate: ${failure.message}');
          emit(CertificateError(message: failure.message));
        },
        (certificate) {
          debugPrint('✅ BLoC: Certificate loaded successfully');
          emit(CertificateLoaded(certificate: certificate));
        },
      );
    } catch (e) {
      debugPrint('❌ BLoC: Unexpected error: $e');
      emit(CertificateError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onFetchMyCertificates(
    FetchMyCertificatesRequested event,
    Emitter<CertificateState> emit,
  ) async {
    emit(const CertificateLoading());
    await _fetchMyCertificates(emit);
  }

  Future<void> _onRefreshCertificates(
    RefreshCertificatesRequested event,
    Emitter<CertificateState> emit,
  ) async {
    // Don't show loading for refresh, keep current data visible
    await _fetchMyCertificates(emit);
  }

  Future<void> _fetchMyCertificates(Emitter<CertificateState> emit) async {
    try {
      debugPrint('📋 BLoC: Fetching my certificates...');
      
      final result = await repository.getMyCertificates();
      
      result.fold(
        (failure) {
          debugPrint('❌ BLoC: Failed to fetch my certificates: ${failure.message}');
          emit(CertificateError(message: failure.message));
        },
        (certificates) {
          debugPrint('✅ BLoC: My certificates loaded successfully');
          debugPrint('📊 Total certificates: ${certificates.length}');
          emit(MyCertificatesLoaded(certificates: certificates));
        },
      );
    } catch (e) {
      debugPrint('❌ BLoC: Unexpected error: $e');
      emit(CertificateError(message: 'An unexpected error occurred'));
    }
  }
}