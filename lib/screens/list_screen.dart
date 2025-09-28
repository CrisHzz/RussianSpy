import 'package:flutter/material.dart';
import '../ui/widgets/spy_app_bar.dart';
import '../ui/widgets/spy_background.dart';
import '../models/person.dart';
import '../services/person_storage_service.dart';
import '../services/fake_service.dart';
import 'form_screen.dart';
import 'detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final PersonStorageService _storageService = PersonStorageService.instance;
  final UserService _userService = const UserService();
  List<Person> _persons = [];
  bool _isLoading = true;
  bool _isGenerating = false;

  static const red = Color(0xFFFF4D4D);
  static const surface = Color(0xFF161B22);

  @override
  void initState() {
    super.initState();
    _loadPersons();
  }

  Future<void> _loadPersons() async {
    setState(() => _isLoading = true);
    final persons = await _storageService.getAllPersons();
    setState(() {
      _persons = persons;
      _isLoading = false;
    });
  }

  Future<void> _deletePerson(String email) async {
    final success = await _storageService.deletePerson(email);
    if (success) {
      _loadPersons();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Identity deleted successfully'),
            backgroundColor: red.withValues(alpha: 0.8),
          ),
        );
      }
    }
  }

  void _navigateToForm([Person? person]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormScreen(person: person)),
    );
    if (result == true) {
      _loadPersons();
    }
  }

  void _navigateToDetail(Person person) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(person: person)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SpyAppBar(onAllIdentities: () => _loadPersons()),
      body: SpyBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: red))
            : _persons.isEmpty
            ? _buildEmptyState()
            : _buildPersonsList(),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "generate",
            onPressed: _isGenerating ? null : _generateMoreIdentities,
            backgroundColor: _isGenerating
                ? Colors.grey[800]
                : Colors.green.withValues(alpha: 0.2),
            foregroundColor: _isGenerating ? Colors.grey[600] : Colors.green,
            elevation: 8,
            child: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "manual",
            onPressed: () => _navigateToForm(),
            backgroundColor: red.withValues(alpha: 0.2),
            foregroundColor: red,
            elevation: 8,
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'NO IDENTITIES FOUND',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate random Russian identities\nor create custom ones',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _persons.length,
      itemBuilder: (context, index) {
        final person = _persons[index];
        return _buildPersonCard(person);
      },
    );
  }

  Widget _buildPersonCard(Person person) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: red.withValues(alpha: 0.2),
          child: Text(
            person.fullName.isNotEmpty ? person.fullName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: red,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
        title: Text(
          person.fullName.isNotEmpty ? person.fullName : 'Unknown Agent',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Text(
          person.email.isNotEmpty ? person.email : 'No contact info',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => _navigateToDetail(person),
              tooltip: 'View Details',
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _navigateToForm(person),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: red),
              onPressed: () => _showDeleteDialog(person),
              tooltip: 'Delete',
            ),
          ],
        ),
        onTap: () => _navigateToDetail(person),
      ),
    );
  }

  void _showDeleteDialog(Person person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        title: const Text(
          'DELETE IDENTITY',
          style: TextStyle(
            color: red,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${person.fullName}?\nThis action cannot be undone.',
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.grey[400],
                fontFamily: 'monospace',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePerson(person.email);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: red.withValues(alpha: 0.2),
              foregroundColor: red,
            ),
            child: const Text(
              'DELETE',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateMoreIdentities() async {
    setState(() => _isGenerating = true);

    try {
      // Generate 5 more random Russian identities
      final newPersons = await _userService.fetchPersons();

      // Save all generated persons to local storage
      for (final person in newPersons) {
        await _storageService.savePerson(person);
      }

      // Reload the list to show new identities
      await _loadPersons();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generated ${newPersons.length} new identities!'),
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate identities: $e'),
            backgroundColor: red.withValues(alpha: 0.8),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}
