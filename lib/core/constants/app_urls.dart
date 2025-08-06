class AppUrls {
  static const String baseUrl = 'http://localhost:8000/api';
  static const String storageUrl = 'http://localhost:8000/storage';

  // Auth endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String register = '/register';
  static const String verifyEmailCode = '/verify-email-code';
  static const String me = '/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh';
  static const String resendOTP = '/auth/resend-otp';

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
