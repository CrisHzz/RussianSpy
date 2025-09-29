import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/widgets/spy_app_bar.dart';
import '../ui/widgets/spy_background.dart';
import '../models/person.dart';
import '../providers/person_provider.dart';
import 'form_screen.dart';
import 'detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  static const red = Color(0xFFFF4D4D);
  static const surface = Color(0xFF161B22);

  @override
  void initState() {
    super.initState();
    // Cargar las personas cuando se abre la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonProvider>().loadPersons();
    });
    
    // setup el scroll infinito
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        //cargar mas cuando el usuario esta a 200 pixels del final
      context.read<PersonProvider>().loadMorePersons();
    }
  }

  Future<void> _deletePerson(String email) async {
    final provider = context.read<PersonProvider>();
    final success = await provider.deletePerson(email);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Identity deleted successfully'),
            backgroundColor: Colors.green.withValues(alpha: 0.8),
          ),
        );
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

  void _navigateToForm([Person? person]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormScreen(person: person),
      ),
    );
  }

  void _navigateToDetail(Person person) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(person: person),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonProvider>(
      builder: (context, provider, child) {
    return Scaffold(
          appBar: SpyAppBar(
            onAllIdentities: () => provider.loadPersons(),
          ),
          body: SpyBackground(
            child: Column(
              children: [
                _buildSearchBar(provider),
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: red),
                        )
                      : provider.persons.isEmpty
                          ? _buildEmptyState(provider)
                          : RefreshIndicator(
                              onRefresh: () => provider.loadPersons(),
                              color: red,
                              backgroundColor: surface,
                              child: _buildPersonsList(provider.persons),
                            ),
                ),
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: "generate",
                onPressed: provider.isLoading ? null : () => _generateMoreIdentities(provider),
                backgroundColor: provider.isLoading 
                    ? Colors.grey[800] 
                    : Colors.green.withValues(alpha: 0.2),
                foregroundColor: provider.isLoading ? Colors.grey[600] : Colors.green,
                elevation: 8,
                child: provider.isLoading 
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
      },
    );
  }

  Widget _buildSearchBar(PersonProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: red.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
        ),
        decoration: InputDecoration(
          hintText: 'Search identities...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'monospace',
          ),
          prefixIcon: const Icon(Icons.search, color: red),
          suffixIcon: provider.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: red),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: (value) => provider.searchPersons(value),
      ),
    );
  }

  Widget _buildEmptyState(PersonProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            provider.searchQuery.isNotEmpty ? 'NO MATCHES FOUND' : 'NO IDENTITIES FOUND',
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
            provider.searchQuery.isNotEmpty 
                ? 'Try a different search term\nor clear the search'
                : 'Generate random Russian identities\nor create custom ones',
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

  Widget _buildPersonsList(List<Person> persons) {
    return Consumer<PersonProvider>(
      builder: (context, provider, child) {
        final itemCount = persons.length + (provider.hasMoreData ? 1 : 0);
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // Show loading indicator at the end if there's more data
            if (index == persons.length) {
              return _buildLoadingIndicator();
            }
            
            final person = persons[index];
            return _buildPersonCard(person);
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: red,
            strokeWidth: 2,
          ),
          const SizedBox(height: 8),
          Text(
            'Loading more identities...',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(Person person) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: red.withValues(alpha: 0.2),
          width: 1,
        ),
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
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
          ),
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

  Future<void> _generateMoreIdentities(PersonProvider provider) async {
    await provider.generateIdentities();
    
    if (mounted) {
      if (provider.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage),
            backgroundColor: red.withValues(alpha: 0.8),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Generated 5 new identities!'),
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
