class AppUrls {
  static const String baseUrl = 'https://api.eventregistration.com';

  // Registration endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String registerParticipant = '/participants';
  static const String getParticipantByEmail = '/participants/by-email';
  static const String getAllParticipants = '/participants';

  // Dashboard endpoints
  static const String adminDashboardStats = '/admin/dashboard/stats';
  static const String adminParticipants = '/admin/participants';
  static const String adminSessions = '/admin/sessions';
  static const String attendanceAnalytics = '/admin/analytics/attendance';
  static const String participantDashboard = '/participants/dashboard';
  static const String checkInParticipant = '/admin/participants';
  static const String confirmationPdf = '/participants';

  // Utility endpoints
  static const String uploadFile = '/upload';
  static const String downloadFile = '/download';
}
