# RussianSpy

**ROLPLAYER**: You are the new leader of Agents division of SVR (внешней разведки Российской Федерации) of russia , your mission is get the best agents of the differents oblast of mother russia and save the identity of them.

A flutter app for create diferrents identities for hide your steps like a secret russian spy.

[Russian Spy app - YouTube](https://youtu.be/iNQM1NPQ2lI) VIDEO


## Como funciona el api

Faker api es una app de caracter publico que sirve para crear datos falsos sobre una persona o ente, es decir genera aleatoriamente para crear una entidad de una persona, es muy usada para registrarse en paginas web o simplementar para crear a una persona.

Esta brinda un servicio gratuito pero sencillo donde simplemente al seleccionar la region de la persona se adaptara el nombre , numero y correo que provenga de ese pais.

```
const UserService({this.locale = "ru_RU", this.quantity = 5});


  Future<List<Person>> fetchPersons() async {
    final url = Uri.parse(
      "https://fakerapi.it/api/v1/persons?_locale=$locale&_quantity=$quantity",
    );
    
```

En este caso aqui estamos utilizando la api para tener 5 registros provenientes de rusia para el funcionamiento de nuestr aplicacion.

Sin embargo hay un problema , esta retorna la informacion el el alfabeto proveniente del pais solicitado haciendo que en casos como , china , india o rusia tengan su alfabeto (Cirilico en su caso), por lo que toca traducir para que quede en nuestro alfabeto romano

```
String transliterate(String text) {
    const translitMap = {
      'А': 'A',
      'Б': 'B',
      'В': 'V',
      'Г': 'G',
      'Д': 'D',
      'Е': 'E',
      'Ё': 'Yo',
      'Ж': 'Zh',
      'З': 'Z',
      'И': 'I',
      'Й': 'Y',
      'К': 'K',
      'Л': 'L',
      'М': 'M',
      'Н': 'N',
      'О': 'O',
      'П': 'P',
      'Р': 'R',
      'С': 'S',
      'Т': 'T',
      'У': 'U',
      'Ф': 'F',
      'Х': 'Kh',
      'Ц': 'Ts',
      'Ч': 'Ch',
      'Ш': 'Sh',
      'Щ': 'Shch',
      'Ъ': '',
      'Ы': 'Y',
      'Ь': '',
      'Э': 'E',
      'Ю': 'Yu',
      'Я': 'Ya',
      'а': 'a',
      'б': 'b',
      'в': 'v',
      'г': 'g',
      'д': 'd',
      'е': 'e',
      'ё': 'yo',
      'ж': 'zh',
      'з': 'z',
      'и': 'i',
      'й': 'y',
      'к': 'k',
      'л': 'l',
      'м': 'm',
      'н': 'n',
      'о': 'o',
      'п': 'p',
      'р': 'r',
      'с': 's',
      'т': 't',
      'у': 'u',
      'ф': 'f',
      'х': 'kh',
      'ц': 'ts',
      'ч': 'ch',
      'ш': 'sh',
      'щ': 'shch',
      'ъ': '',
      'ы': 'y',
      'ь': '',
      'э': 'e',
      'ю': 'yu',
      'я': 'ya',
    };
    final sb = StringBuffer();
    for (final ch in text.runes) {
      final s = String.fromCharCode(ch);
      sb.write(translitMap[s] ?? s);
    }
    return sb.toString();
  }
}
```
Como recuerdan el metodo solamente trae datos , por lo que todo  genera todo el CRUD para generar las operaciones de tipo **GET**,**CREATE**,**POST**,**DELETE**


```
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
```
Aqui es donde creamos lo que nos falta y con esto ya tenemos lista la api que usaremos en nuestra app

