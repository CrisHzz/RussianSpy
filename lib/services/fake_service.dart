// lib/services/faker_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/person.dart';

class UserService {
  final String locale;
  final int quantity;

  const UserService({this.locale = "ru_RU", this.quantity = 5});

  //obtener personas usando la api de fakerapi

  Future<List<Person>> fetchPersons() async {
    final url = Uri.parse(
      "https://fakerapi.it/api/v1/persons?_locale=$locale&_quantity=$quantity",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List personsJson = (data["data"] as List);

        return personsJson.map<Person>((raw) {
          final m = Map<String, dynamic>.from(raw as Map);

          m['firstname'] = transliterate(m['firstname'] ?? '');
          m['lastname'] = transliterate(m['lastname'] ?? '');
          return Person.fromFakerJson(m);
        }).toList();
      } else {
        throw Exception("Error al cargar datos: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error en la petición: $e");
    }
  }

  // Cambiar de alfabeto cirilico a romano
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
