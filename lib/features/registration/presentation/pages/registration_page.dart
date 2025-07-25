import 'dart:io';

import 'package:event_reg/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:event_reg/features/registration/presentation/bloc/registration_event.dart';
import 'package:event_reg/features/registration/presentation/bloc/registration_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Controllers for form fields
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _regionController = TextEditingController();
  final _cityController = TextEditingController();
  final _woredaController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _occupationController = TextEditingController();
  final _organizationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _otpController = TextEditingController();

  // Form values
  String? _selectedGender;
  DateTime? _dateOfBirth;
  String? _selectedNationality;
  String? _selectedIndustry;
  int? _yearsOfExperience;
  File? _profileImage;
  final List<String> _selectedSessions = [];

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _nationalities = ['Ethiopian', 'Other'];
  final List<String> _industries = [
    'Education',
    'Health',
    'Technology',
    'Government',
    'Banking',
    'Manufacturing',
    'Agriculture',
    'Other',
  ];

  final List<Map<String, String>> _availableSessions = [
    {'id': '1', 'title': 'Opening Ceremony', 'time': '9:00 AM - 10:00 AM'},
    {
      'id': '2',
      'title': 'Digital Transformation',
      'time': '10:30 AM - 12:00 PM',
    },
    {'id': '3', 'title': 'Innovation Workshop', 'time': '2:00 PM - 4:00 PM'},
    {'id': '4', 'title': 'Networking Session', 'time': '4:30 PM - 6:00 PM'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Registration'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is OTPSentState) {
            _nextStep();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP sent to your email!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is RegistrationSuccessState) {
            Navigator.pushReplacementNamed(
              context,
              '/confirmation',
              arguments: state,
            );
          }
        },
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalInfoStep(),
                  _buildProfessionalInfoStep(),
                  _buildSessionSelectionStep(),
                  _buildOTPVerificationStep(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _regionController.dispose();
    _cityController.dispose();
    _woredaController.dispose();
    _idNumberController.dispose();
    _occupationController.dispose();
    _organizationController.dispose();
    _departmentController.dispose();
    _otpController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildNavigationButtons() {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: state is RegistrationLoading
                        ? null
                        : _previousStep,
                    child: const Text('Previous'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: state is RegistrationLoading
                      ? null
                      : _handleNextButton,
                  child: state is RegistrationLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(_getButtonText()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOTPVerificationStep() {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Verification',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a verification code to ${_emailController.text}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'Enter Verification Code',
                  prefixIcon: Icon(Icons.security),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, letterSpacing: 4),
              ),
              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: state is RegistrationLoading
                      ? null
                      : () {
                          context.read<RegistrationBloc>().add(
                            SendOTPEvent(email: _emailController.text),
                          );
                        },
                  child: Text(
                    state is RegistrationLoading ? 'Sending...' : 'Resend Code',
                  ),
                ),
              ),

              if (state is RegistrationLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            _buildProfileImagePicker(),
            const SizedBox(height: 16),

            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: _genders.map((gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _dateOfBirth != null
                      ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                      : 'Select date',
                ),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedNationality,
              decoration: const InputDecoration(
                labelText: 'Nationality',
                prefixIcon: Icon(Icons.flag),
              ),
              items: _nationalities.map((nationality) {
                return DropdownMenuItem(
                  value: nationality,
                  child: Text(nationality),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedNationality = value;
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _regionController,
                    decoration: const InputDecoration(
                      labelText: 'Region',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _woredaController,
              decoration: const InputDecoration(
                labelText: 'Woreda',
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _idNumberController,
              decoration: const InputDecoration(
                labelText: 'ID/Passport Number',
                prefixIcon: Icon(Icons.credit_card),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _occupationController,
            decoration: const InputDecoration(
              labelText: 'Occupation/Job Title *',
              prefixIcon: Icon(Icons.work),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your occupation';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _organizationController,
            decoration: const InputDecoration(
              labelText: 'Organization/Company *',
              prefixIcon: Icon(Icons.business),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your organization';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _departmentController,
            decoration: const InputDecoration(
              labelText: 'Department/Unit',
              prefixIcon: Icon(Icons.group),
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedIndustry,
            decoration: const InputDecoration(
              labelText: 'Industry/Sector *',
              prefixIcon: Icon(Icons.category),
            ),
            items: _industries.map((industry) {
              return DropdownMenuItem(value: industry, child: Text(industry));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedIndustry = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your industry';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Years of Experience',
              prefixIcon: Icon(Icons.timeline),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _yearsOfExperience = int.tryParse(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : null,
            child: _profileImage == null
                ? Icon(Icons.person, size: 50, color: Colors.grey.shade600)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSessionSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Sessions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the sessions you want to attend',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          ..._availableSessions.map((session) {
            final isSelected = _selectedSessions.contains(session['id']);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                title: Text(session['title']!),
                subtitle: Text(session['time']!),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedSessions.add(session['id']!);
                    } else {
                      _selectedSessions.remove(session['id']);
                    }
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Next';
      case 1:
        return 'Next';
      case 2:
        return 'Send OTP';
      case 3:
        return 'Complete Registration';
      default:
        return 'Next';
    }
  }

  void _handleNextButton() {
    switch (_currentStep) {
      case 0:
        if (_formKey.currentState!.validate()) {
          _nextStep();
        }
        break;
      case 1:
        if (_validateProfessionalInfo()) {
          _nextStep();
        }
        break;
      case 2:
        if (_selectedSessions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one session')),
          );
          return;
        }
        // Send OTP
        context.read<RegistrationBloc>().add(
          SendOTPEvent(email: _emailController.text),
        );
        break;
      case 3:
        // Verify OTP and complete registration
        if (_otpController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter the verification code')),
          );
          return;
        }

        context.read<RegistrationBloc>().add(
          VerifyOTPEvent(
            email: _emailController.text,
            otp: _otpController.text,
          ),
        );

        // If OTP is valid, register participant
        context.read<RegistrationBloc>().add(
          RegisterParticipantEvent(
            fullName: _fullNameController.text,
            gender: _selectedGender,
            dateOfBirth: _dateOfBirth,
            nationality: _selectedNationality,
            phoneNumber: _phoneController.text,
            email: _emailController.text,
            region: _regionController.text.isEmpty
                ? null
                : _regionController.text,
            city: _cityController.text.isEmpty ? null : _cityController.text,
            woreda: _woredaController.text.isEmpty
                ? null
                : _woredaController.text,
            idNumber: _idNumberController.text.isEmpty
                ? null
                : _idNumberController.text,
            occupation: _occupationController.text,
            organization: _organizationController.text,
            department: _departmentController.text.isEmpty
                ? null
                : _departmentController.text,
            industry: _selectedIndustry!,
            yearsOfExperience: _yearsOfExperience,
            photoPath: _profileImage?.path,
            selectedSessions: _selectedSessions,
          ),
        );
        break;
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _dateOfBirth ??
          DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  bool _validateProfessionalInfo() {
    if (_occupationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your occupation')),
      );
      return false;
    }
    if (_organizationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your organization')),
      );
      return false;
    }
    if (_selectedIndustry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your industry')),
      );
      return false;
    }
    return true;
  }
}
