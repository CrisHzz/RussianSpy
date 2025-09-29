import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/person_storage_service.dart';
import '../services/fake_service.dart';

enum OperationStatus { idle, loading, success, error }

class PersonProvider extends ChangeNotifier {
  final PersonStorageService _storageService = PersonStorageService.instance;
  final UserService _userService = const UserService();

  List<Person> _allPersons = [];
  List<Person> _displayedPersons = [];
  String _searchQuery = '';
  OperationStatus _status = OperationStatus.idle;
  String _errorMessage = '';
  
  // Paginacion
  static const int _itemsPerPage = 10;
  int _currentPage = 0;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  // Getters
  List<Person> get persons => _displayedPersons;
  String get searchQuery => _searchQuery;
  OperationStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == OperationStatus.loading;
  bool get hasError => _status == OperationStatus.error;
  bool get hasMoreData => _hasMoreData;
  bool get isLoadingMore => _isLoadingMore;

  // Cargar e inicializar las personas
  Future<void> loadPersons() async {
    _setStatus(OperationStatus.loading);
    try {
      _allPersons = await _storageService.getAllPersons();
      _resetPagination();
      _loadNextPage();
      _setStatus(OperationStatus.success);
    } catch (e) {
      _setError('Failed to load identities: $e');
    }
  }

  // Personas aleatorias
  Future<void> generateIdentities() async {
    _setStatus(OperationStatus.loading);
    try {
      final newPersons = await _userService.fetchPersons();
      for (final person in newPersons) {
        await _storageService.savePerson(person);
      }
      await loadPersons(); 
      _setStatus(OperationStatus.success);
    } catch (e) {
      _setError('Failed to generate identities: $e');
    }
  }

  // Guardar a una persona
  Future<bool> savePerson(Person person) async {
    _setStatus(OperationStatus.loading);
    try {
      final success = await _storageService.savePerson(person);
      if (success) {
        await loadPersons(); 
        _setStatus(OperationStatus.success);
        return true;
      } else {
        _setError('Failed to save identity');
        return false;
      }
    } catch (e) {
      _setError('Failed to save identity: $e');
      return false;
    }
  }

  // Eliminar a una persona
  Future<bool> deletePerson(String email) async {
    _setStatus(OperationStatus.loading);
    try {
      final success = await _storageService.deletePerson(email);
      if (success) {
        await loadPersons();
        _setStatus(OperationStatus.success);
        return true;
      } else {
        _setError('Failed to delete identity');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete identity: $e');
      return false;
    }
  }

  // Filtrar
  void searchPersons(String query) {
    _searchQuery = query.toLowerCase();
    _resetPagination();
    _loadNextPage();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _resetPagination();
    _loadNextPage();
    notifyListeners();
  }

  // El scroll infinito
  Future<void> loadMorePersons() async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    // Delay para que se vea mejorcito
    await Future.delayed(const Duration(milliseconds: 500));
    
    _loadNextPage();
    
    _isLoadingMore = false;
    notifyListeners();
  }

  void _resetPagination() {
    _currentPage = 0;
    _displayedPersons.clear();
    _hasMoreData = true;
  }

  void _loadNextPage() {
    final filteredPersons = _getFilteredPersons();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredPersons.length);
    
    if (startIndex >= filteredPersons.length) {
      _hasMoreData = false;
      return;
    }
    
    final newItems = filteredPersons.sublist(startIndex, endIndex);
    _displayedPersons.addAll(newItems);
    _currentPage++;
    
    _hasMoreData = endIndex < filteredPersons.length;
  }

  List<Person> _getFilteredPersons() {
    if (_searchQuery.isEmpty) {
      return _allPersons;
    } else {
      return _allPersons.where((person) {
        return person.fullName.toLowerCase().contains(_searchQuery) ||
               person.email.toLowerCase().contains(_searchQuery) ||
               person.phone.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }

  void _setStatus(OperationStatus status) {
    _status = status;
    if (status != OperationStatus.error) {
      _errorMessage = '';
    }
    notifyListeners();
  }

  void _setError(String message) {
    _status = OperationStatus.error;
    _errorMessage = message;
    notifyListeners();
  }


  void clearError() {
    if (_status == OperationStatus.error) {
      _status = OperationStatus.idle;
      _errorMessage = '';
      notifyListeners();
    }
  }
}
