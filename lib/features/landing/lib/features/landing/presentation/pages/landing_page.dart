import 'package:flutter/material.dart';
import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/config/themes/app_colors.dart';
import 'package:event_reg/core/widgets/custom_button.dart';

import '../widgets/event_highlights.dart';
import '../widgets/event_info.dart';
import '../widgets/hero_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with App Bar
            const HeroSection(),

            // Event Information Section
            const EventInfoSection(),

            // Event Highlights
            const EventHighlightsCard(),

            // Action Buttons Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Register Now Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Register Now',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteNames.registrationPage,
                        );
                      },
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Already Registered Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Already Registered? Sign In',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteNames.participantLoginPage,
                        );
                      },
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.primary,
                      borderColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Access Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Event Agenda',
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              RouteNames.eventAgendaPage,
                            );
                          },
                          backgroundColor: AppColors.secondary,
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: 'Contact Us',
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              RouteNames.contactPage,
                            );
                          },
                          backgroundColor: AppColors.secondary,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Admin Access (Hidden/Small Link)
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.adminLoginPage);
                },
                child: Text(
                  'Admin Access',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
