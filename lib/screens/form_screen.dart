import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/widgets/spy_app_bar.dart';
import '../ui/widgets/spy_background.dart';
import '../models/person.dart';
import '../providers/person_provider.dart';


//Esta pantalla muestra el formulario para  actualizar una persona
class FormScreen extends StatefulWidget {
  final Person? person;
  
  const FormScreen({super.key, this.person});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String _selectedGender = 'Male';
  
  bool _isLoading = false;
  bool get _isEditing => widget.person != null;

  static const red = Color(0xFFFF4D4D);
  static const surface = Color(0xFF161B22);

  @override
  void initState() {
    super.initState();
    
    try {
      // Inicializacion basica
      _firstnameController = TextEditingController(text: widget.person?.firstname?.trim() ?? '');
      _lastnameController = TextEditingController(text: widget.person?.lastname?.trim() ?? '');
      _emailController = TextEditingController(text: widget.person?.email?.trim() ?? '');
      _phoneController = TextEditingController(text: widget.person?.phone?.trim() ?? '');
      
      // Normalizar el valor del genero para que coincida con las opciones del dropdown
      _selectedGender = _normalizeGender(widget.person?.gender);
      
      // Verificar que el genero normalizado es valido
      const validGenders = ['Male', 'Female', 'Other'];
      if (!validGenders.contains(_selectedGender)) {
        print('Warning: Normalized gender "$_selectedGender" is still invalid, forcing to Male');
        _selectedGender = 'Male';
      }
    } catch (e) {
      print('Error initializing form: $e');
      _firstnameController = TextEditingController(text: '');
      _lastnameController = TextEditingController(text: '');
      _emailController = TextEditingController(text: '');
      _phoneController = TextEditingController(text: '');
      _selectedGender = 'Male';
    }
  }

  //Casos de uso para el genero
  String _normalizeGender(String? gender) {
    if (gender == null) {
      print('Debug: Gender is null, defaulting to Male');
      return 'Male';
    }
    
    final normalizedGender = gender.trim();
    if (normalizedGender.isEmpty) {
      print('Debug: Gender is empty, defaulting to Male');
      return 'Male';
    }
    
    print('Debug: Original gender value: "$normalizedGender" (length: ${normalizedGender.length})');
    
    
    const validOptions = ['Male', 'Female', 'Other'];
    if (validOptions.contains(normalizedGender)) {
      print('Debug: Gender already normalized: "$normalizedGender"');
      return normalizedGender;
    }
    
    // Diferentes variantes del genero
    final lowerGender = normalizedGender.toLowerCase();
    print('Debug: Lowercase gender: "$lowerGender"');
    
    switch (lowerGender) {
      case 'male':
      case 'm':
      case 'мужской':
      case 'мужчина':
      case 'man':
        print('Debug: Mapping "$normalizedGender" to Male');
        return 'Male';
      case 'female':
      case 'f':
      case 'женский':
      case 'женщина':
      case 'woman':
        print('Debug: Mapping "$normalizedGender" to Female');
        return 'Female';
      default:
        print('Debug: Unknown gender "$normalizedGender" (lowercase: "$lowerGender"), defaulting to Other');
        return 'Other';
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _savePerson() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final person = Person(
      firstname: _firstnameController.text.trim(),
      lastname: _lastnameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _selectedGender,
    );

    final provider = context.read<PersonProvider>();
    final success = await provider.savePerson(person);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Identity updated successfully' : 'Identity created successfully'),
            backgroundColor: Colors.green.withValues(alpha: 0.8),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage),
            backgroundColor: red.withValues(alpha: 0.8),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SpyAppBar(
        onAllIdentities: () => Navigator.pop(context),
      ),
      body: SpyBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildFormFields(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          _isEditing ? Icons.edit_note : Icons.add_moderator,
          size: 48,
          color: red,
        ),
        const SizedBox(height: 16),
        Text(
          _isEditing ? 'EDIT IDENTITY' : 'CREATE IDENTITY',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: red,
            letterSpacing: 2,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isEditing ? 'Update spy information' : 'Register new spy identity',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _firstnameController,
          label: 'First Name',
          icon: Icons.person,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'First name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _lastnameController,
          label: 'Last Name',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Last name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildGenderDropdown(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: red.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'monospace',
          ),
          prefixIcon: Icon(icon, color: red),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    const genderOptions = ['Male', 'Female', 'Other'];
    
    String safeSelectedGender = genderOptions.contains(_selectedGender) ? _selectedGender : 'Male';
    
    return Container(
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: red.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: safeSelectedGender,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
        ),
        dropdownColor: surface,
        decoration: InputDecoration(
          labelText: 'Gender',
          labelStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'monospace',
          ),
          prefixIcon: const Icon(Icons.wc, color: red),
          border: InputBorder.none,
        ),
        items: genderOptions.map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(
              gender,
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.white,
              ),
            ),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a gender';
          }
          return null;
        },
        onChanged: (String? newValue) {
          if (newValue != null && ['Male', 'Female', 'Other'].contains(newValue)) {
            setState(() => _selectedGender = newValue);
            print('Debug: Gender changed to: "$newValue"');
          }
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _savePerson,
            style: ElevatedButton.styleFrom(
              backgroundColor: red.withValues(alpha: 0.2),
              foregroundColor: red,
              disabledBackgroundColor: Colors.grey[800],
              disabledForegroundColor: Colors.grey[600],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: red.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: red,
                    ),
                  )
                : Icon(_isEditing ? Icons.save : Icons.add_moderator),
            label: Text(
              _isLoading 
                  ? 'PROCESSING...' 
                  : _isEditing 
                      ? 'UPDATE IDENTITY' 
                      : 'CREATE IDENTITY',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
