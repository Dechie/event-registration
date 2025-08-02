import 'dart:async';

import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:event_reg/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:event_reg/features/auth/presentation/bloc/states/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthOTPVerificationPage extends StatefulWidget {
  final String email;
  final String? otpToken;
  final String? message;

  const AuthOTPVerificationPage({
    super.key,
    required this.email,
    this.otpToken,
    this.message,
  });

  @override
  State<AuthOTPVerificationPage> createState() =>
      _AuthOTPVerificationPageState();
}

class _AuthOTPVerificationPageState extends State<AuthOTPVerificationPage>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Clear OTP fields on error
            _clearOTPFields();
          } else if (state is AuthOTPVerifiedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Navigate to login page after successful verification
            Navigator.of(context).pushNamedAndRemoveUntil(
              RouteNames.participantLoginPage,
              (route) => false,
            );
          } else if (state is AuthOTPSentState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _startResendTimer();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildVerificationForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _resendTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startResendTimer();
  }

  Widget _buildChangeEmailOption() {
    return TextButton.icon(
      onPressed: () {
        Navigator.pushReplacementNamed(
          context,
          RouteNames.userRegistrationPage,
        );
      },
      icon: Icon(Icons.edit, size: 16, color: Colors.grey[600]),
      label: Text(
        'Change Email Address',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Verify Your Email',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Column(
      children: [
        Text(
          'We\'ve sent a 6-digit verification code to:',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.email,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Please enter the code to verify your email address.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOTPFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 35,
          height: 45,
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onChanged: (value) => _onOTPChanged(value, index),
          ),
        );
      }),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          'Didn\'t receive the code?',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoadingState;

            return TextButton(
              onPressed: (_canResend && !isLoading) ? _handleResendOTP : null,
              child: Text(
                _canResend ? 'Resend Code' : 'Resend in ${_resendCountdown}s',
                style: TextStyle(
                  color: _canResend
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVerificationForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 32),

              // Instructions
              _buildInstructions(),
              const SizedBox(height: 24),

              // OTP Input Fields
              _buildOTPFields(),
              const SizedBox(height: 24),

              // Verify Button
              _buildVerifyButton(),
              const SizedBox(height: 16),

              // Resend Section
              _buildResendSection(),
              const SizedBox(height: 16),

              // Change Email
              _buildChangeEmailOption(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;
        final isOTPComplete = _otpControllers.every(
          (controller) => controller.text.isNotEmpty,
        );

        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: (isLoading || !isOTPComplete)
                ? null
                : _handleVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Verify Email',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        );
      },
    );
  }

  void _clearOTPFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _handleResendOTP() {
    // Clear existing OTP
    _clearOTPFields();

    // Dispatch resend event
    context.read<AuthBloc>().add(ResendOTPEvent(email: widget.email));
  }

  void _handleVerification() {
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length == 6) {
      // Hide keyboard
      FocusScope.of(context).unfocus();

      // Dispatch verification event
      context.read<AuthBloc>().add(
        VerifyOTPEvent(
          email: widget.email,
          otp: otp,
          otpToken: widget.otpToken,
        ),
      );
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

    _animationController.forward();
  }

  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all fields are filled
    if (_otpControllers.every((controller) => controller.text.isNotEmpty)) {
      _handleVerification();
    }
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _canResend = false;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }
}
