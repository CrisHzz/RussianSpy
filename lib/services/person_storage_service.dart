import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';


//servicio para guardar y obtener las personas usando shared_preferences
class PersonStorageService {
  static const String _personsKey = 'spy_persons';
  static PersonStorageService? _instance;
  
  PersonStorageService._internal();
  
  static PersonStorageService get instance {
    _instance ??= PersonStorageService._internal();
    return _instance!;
  }
  // Funciones de tipo GET
  Future<List<Person>> getAllPersons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final personsJson = prefs.getStringList(_personsKey) ?? [];
      
      return personsJson
          .map((jsonString) => Person.fromFakerJson(jsonDecode(jsonString)))
          .toList();
    } catch (e) {
      print('Error loading persons: $e');
      return [];
    }
  }

  Future<Person?> getPersonByEmail(String email) async {
    final persons = await getAllPersons();
    try {
      return persons.firstWhere((person) => person.email == email);
    } catch (e) {
      return null;
    }
  }

  // Funciones de tipo POST/PUT
  Future<bool> savePerson(Person person) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final persons = await getAllPersons();
      
      persons.removeWhere((existing) => existing.email == person.email);
      
      persons.add(person);
      
      final personsJson = persons
          .map((person) => jsonEncode(person.toJson()))
          .toList();
      
      return await prefs.setStringList(_personsKey, personsJson);
    } catch (e) {
      print('Error saving person: $e');
      return false;
    }
  }

  // Funciones de tipo DELETE
  Future<bool> deletePerson(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final persons = await getAllPersons();
      
      persons.removeWhere((person) => person.email == email);
      
      final personsJson = persons
          .map((person) => jsonEncode(person.toJson()))
          .toList();
      
      return await prefs.setStringList(_personsKey, personsJson);
    } catch (e) {
      print('Error deleting person: $e');
      return false;
    }
  }

  Future<bool> clearAllPersons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_personsKey);
    } catch (e) {
      print('Error clearing persons: $e');
      return false;
    }
  }
}
