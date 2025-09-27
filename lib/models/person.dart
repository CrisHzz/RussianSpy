// lib/models/person.dart
class Person {
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String gender;

  const Person({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.gender,
  });

  String get fullName => '$firstname $lastname';

  factory Person.fromFakerJson(Map<String, dynamic> json) {
    return Person(
      firstname: (json['firstname'] ?? '') as String,
      lastname:  (json['lastname']  ?? '') as String,
      email:     (json['email']     ?? '') as String,
      phone:     (json['phone']     ?? '') as String,
      gender:    (json['gender']    ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'firstname': firstname,
    'lastname' : lastname,
    'email'    : email,
    'phone'    : phone,
    'gender'   : gender,
  };
}
