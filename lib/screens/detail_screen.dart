import 'package:flutter/material.dart';
import '../ui/widgets/spy_app_bar.dart';
import '../ui/widgets/spy_background.dart';
import '../models/person.dart';
import 'form_screen.dart';

class DetailScreen extends StatelessWidget {
  final Person person;

  const DetailScreen({super.key, required this.person});

  static const red = Color(0xFFFF4D4D);
  static const surface = Color(0xFF161B22);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SpyAppBar(onAllIdentities: () => Navigator.pop(context)),
      body: SpyBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildPersonInfo(),
              const SizedBox(height: 32),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: red.withValues(alpha: 0.2),
            border: Border.all(color: red.withValues(alpha: 0.4), width: 2),
            boxShadow: [
              BoxShadow(
                color: red.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              person.fullName.isNotEmpty
                  ? person.fullName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: red,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'IDENTITY PROFILE',
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
          'Classified Information',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildPersonInfo() {
    return Column(
      children: [
        _buildInfoCard(
          icon: Icons.person,
          label: 'Full Name',
          value: person.fullName.isNotEmpty ? person.fullName : 'Not specified',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.email,
          label: 'Email',
          value: person.email.isNotEmpty ? person.email : 'Not specified',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.phone,
          label: 'Phone',
          value: person.phone.isNotEmpty ? person.phone : 'Not specified',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.wc,
          label: 'Gender',
          value: person.gender.isNotEmpty ? person.gender : 'Not specified',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.badge,
          label: 'Agent Code',
          value: _generateAgentCode(),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: red.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: red.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: red, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToEdit(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: red.withValues(alpha: 0.2),
              foregroundColor: red,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: red.withValues(alpha: 0.4), width: 1),
              ),
            ),
            icon: const Icon(Icons.edit),
            label: const Text(
              'EDIT IDENTITY',
              style: TextStyle(
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
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.arrow_back),
            label: const Text(
              'BACK TO LIST',
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

  String _generateAgentCode() {
    final firstName = person.firstname.isNotEmpty ? person.firstname : 'X';
    final lastName = person.lastname.isNotEmpty ? person.lastname : 'X';
    final emailHash = person.email.isNotEmpty
        ? person.email.hashCode.abs() % 1000
        : 0;

    return '${firstName[0].toUpperCase()}${lastName[0].toUpperCase()}-${emailHash.toString().padLeft(3, '0')}';
  }

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormScreen(person: person)),
    );

    if (result == true) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }
}
