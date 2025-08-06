import 'dart:io';

import 'package:event_reg/config/routes/route_names.dart';
import 'package:event_reg/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:event_reg/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:event_reg/features/auth/presentation/bloc/states/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ProfileAddPage extends StatefulWidget {
  final bool isEditMode;
  final Map<String, dynamic>? existingProfileData;

  const ProfileAddPage({
    super.key,
    this.isEditMode = false,
    this.existingProfileData,
  });

  @override
  State<ProfileAddPage> createState() => _ProfileAddPageState();
}

class _ProfileAddPageState extends State<ProfileAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Controllers for form fields
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regionController = TextEditingController();
  final _cityController = TextEditingController();
  final _woredaController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _occupationController = TextEditingController();
  final _organizationController = TextEditingController();
  final _departmentController = TextEditingController();

  // Form values
  String? _selectedGender;
  DateTime? _dateOfBirth;
  String? _selectedNationality;
  String? _selectedIndustry;
  int? _yearsOfExperience;
  File? _profileImage;

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

  // Get total number of steps based on mode
  int get _totalSteps => widget.isEditMode ? 2 : 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Profile' : 'Create Profile'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is AuthenticatedState ||
              state is AuthProfileCreatedState ||
              state is AuthProfileUpdatedState) {
            if (widget.isEditMode) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(
                context,
              ).pushReplacementNamed(RouteNames.landingPage);
            } else {
              // Profile creation completed successfully
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Navigate based on user role
              final userData = state is AuthenticatedState
                  ? state.userData
                  : null;
              final role = userData?['role'] ?? 'participant';

              if (role == 'admin') {
                // Admin goes to admin dashboard
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.adminDashboardPage,
                  (route) => false,
                );
              } else {
                // Participant goes to landing page
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.landingPage,
                  (route) => false,
                );
              }
            }
          }
        },
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: _buildPages(),
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
    _regionController.dispose();
    _cityController.dispose();
    _woredaController.dispose();
    _idNumberController.dispose();
    _occupationController.dispose();
    _organizationController.dispose();
    _departmentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode && widget.existingProfileData != null) {
      _populateExistingData();
    }
  }

  Future<String?> obtainPhotoPath() async {
    String? finalPhotoPath = _profileImage?.path;
    if (_profileImage == null) {
      try {
        final ByteData byteData = await rootBundle.load(
          "assets/placeholder_profile.jpg",
        );
        final tempDir = await getTemporaryDirectory();
        final file = File(p.join(tempDir.path, 'placeholder_profile.jpg'));

        debugPrint("about to write file as bytes:");
        await file.writeAsBytes(
          byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          ),
        );
        finalPhotoPath = file.path;
        debugPrint("successfully loaded asset: $finalPhotoPath");
        return finalPhotoPath;
      } catch (e) {
        // Handle any errors, e.g., if the asset doesn't exist
        debugPrint("Error creating placeholder file: $e");
        // Optionally, show a snackbar to the user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not prepare placeholder image. Please try again.',
              ),
            ),
          );
        }
        return null;
        // Stop the submission process if there's an error
      }
    }
    return finalPhotoPath;
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isLoading = authState is AuthLoadingState;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _previousStep,
                    child: const Text('Previous'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleNextButton,
                  child: isLoading
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

  List<Widget> _buildPages() {
    if (widget.isEditMode) {
      // Edit mode: only 2 pages (Personal Info -> Professional Info)
      return [_buildPersonalInfoStep(), _buildProfessionalInfoStep()];
    } else {
      // Create mode: 3 pages (Personal Info -> Professional Info -> Preview)
      return [
        _buildPersonalInfoStep(),
        _buildProfessionalInfoStep(),
        _buildPreviewAndConfirmStep(),
      ];
    }
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

  Widget _buildPreviewAndConfirmStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Information',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your information before submitting',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Profile Image Preview
          if (_profileImage != null)
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(_profileImage!),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

          // Personal Information Section
          _buildSectionHeader('Personal Information'),
          _buildInfoCard([
            _buildInfoRow('Full Name', _fullNameController.text),
            if (_selectedGender != null)
              _buildInfoRow('Gender', _selectedGender!),
            if (_dateOfBirth != null)
              _buildInfoRow(
                'Date of Birth',
                '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
              ),
            if (_selectedNationality != null)
              _buildInfoRow('Nationality', _selectedNationality!),
            _buildInfoRow('Phone Number', _phoneController.text),
            if (_regionController.text.isNotEmpty)
              _buildInfoRow('Region', _regionController.text),
            if (_cityController.text.isNotEmpty)
              _buildInfoRow('City', _cityController.text),
            if (_woredaController.text.isNotEmpty)
              _buildInfoRow('Woreda', _woredaController.text),
            if (_idNumberController.text.isNotEmpty)
              _buildInfoRow('ID/Passport Number', _idNumberController.text),
          ]),

          const SizedBox(height: 24),

          // Professional Information Section
          _buildSectionHeader('Professional Information'),
          _buildInfoCard([
            _buildInfoRow('Occupation', _occupationController.text),
            _buildInfoRow('Organization', _organizationController.text),
            if (_departmentController.text.isNotEmpty)
              _buildInfoRow('Department', _departmentController.text),
            if (_selectedIndustry != null)
              _buildInfoRow('Industry', _selectedIndustry!),
            if (_yearsOfExperience != null)
              _buildInfoRow(
                'Years of Experience',
                _yearsOfExperience.toString(),
              ),
          ]),

          const SizedBox(height: 24),

          // Confirmation message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'By clicking "Create Profile", you confirm that the information provided is accurate and complete.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            initialValue: _yearsOfExperience?.toString(),
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
                : const AssetImage('assets/placeholder_profile.jpg')
                      as ImageProvider, // Add placeholder asset
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
        children: List.generate(_totalSteps, (index) {
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Future<void> _createProfile() async {
    debugPrint("before sending to api:");
    debugPrint(
      "fullname: ${_fullNameController.text}, gender: $_selectedGender, occupation: ${_occupationController.text}, organization: ${_organizationController.text} dateofbirth: ${_dateOfBirth?.toIso8601String() ?? "null date"}, nationality: ${_selectedNationality ?? "null nationality"}, phoneNumber: ${_phoneController.text}, region: ${_regionController.text}, city: ${_cityController.text}, woreda: ${_woredaController.text}",
    );
    String? finalPhotoPath = await obtainPhotoPath();

    if (mounted) {
      context.read<AuthBloc>().add(
        CreateProfileEvent(
          fullName: _fullNameController.text,
          gender: _selectedGender,
          dateOfBirth: _dateOfBirth,
          nationality: _selectedNationality,
          phoneNumber: _phoneController.text,
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
          photoPath: finalPhotoPath,
        ),
      );
    }
  }

  String _getButtonText() {
    if (widget.isEditMode) {
      // Edit mode: Step 0 = Next, Step 1 = Update Profile
      switch (_currentStep) {
        case 0:
          return 'Next';
        case 1:
          return 'Update Profile';
        default:
          return 'Next';
      }
    } else {
      // Create mode: Step 0 = Next, Step 1 = Preview, Step 2 = Create Profile
      switch (_currentStep) {
        case 0:
          return 'Next';
        case 1:
          return 'Preview';
        case 2:
          return 'Create Profile';
        default:
          return 'Next';
      }
    }
  }

  void _handleNextButton() {
    if (widget.isEditMode) {
      switch (_currentStep) {
        case 0:
          if (_formKey.currentState!.validate()) {
            _nextStep();
          }
          break;
        case 1:
          if (_validateProfessionalInfo()) {
            _updateProfile();
          }
          break;
      }
    } else {
      switch (_currentStep) {
        case 0:
          if (_formKey.currentState!.validate()) {
            _nextStep();
          }
          break;
        case 1:
          if (_validateProfessionalInfo()) {
            debugPrint("validate prof info success");
            _nextStep();
          } else {
            debugPrint("validate prof info fail");
          }
          break;
        case 2:
          // Create profile using CreateProfileEvent
          _createProfile();
          break;
      }
    }
  }

  void _nextStep() {
    final maxSteps = _totalSteps - 1; // Convert to 0-based index
    debugPrint(
      "max steps: $maxSteps, currentStep: $_currentStep, isEditMode: ${widget.isEditMode}",
    );
    if (_currentStep < maxSteps) {
      setState(() {
        _currentStep++;
      });
      debugPrint("new currentStep: $_currentStep");
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

  void _populateExistingData() {
    final data = widget.existingProfileData!;
    _fullNameController.text = data['fullName'] ?? '';
    _phoneController.text = data['phoneNumber'] ?? '';
    _regionController.text = data['region'] ?? '';
    _cityController.text = data['city'] ?? '';
    _woredaController.text = data['woreda'] ?? '';
    _idNumberController.text = data['idNumber'] ?? '';
    _occupationController.text = data['occupation'] ?? '';
    _organizationController.text = data['organization'] ?? '';
    _departmentController.text = data['department'] ?? '';

    _selectedGender = data['gender'];
    _selectedNationality = data['nationality'];
    _selectedIndustry = data['industry'];
    _yearsOfExperience = data['yearsOfExperience'];

    if (data['dateOfBirth'] != null) {
      _dateOfBirth = DateTime.parse(data['dateOfBirth']);
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

  Future<void> _updateProfile() async {
    debugPrint("full name: ${_fullNameController.text}");

    String? finalPhotoPath = await obtainPhotoPath();
    if (mounted) {
      context.read<AuthBloc>().add(
        CreateProfileEvent(
          // You might want to create a separate UpdateProfileEvent
          fullName: _fullNameController.text,
          gender: _selectedGender,
          dateOfBirth: _dateOfBirth,
          nationality: _selectedNationality,
          phoneNumber: _phoneController.text,
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
          photoPath: finalPhotoPath,
        ),
      );
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
