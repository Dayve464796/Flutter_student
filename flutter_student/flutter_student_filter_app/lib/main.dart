import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liste des étudiants',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: StudentListPage(),
    );
  }
}

class Student {
  final String nom;
  final String prenom;
  final String classe;
  final String matricule;
  final String email;

  Student({
    required this.nom,
    required this.prenom,
    required this.classe,
    required this.matricule,
    required this.email,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      nom: json['nom'],
      prenom: json['prenom'],
      classe: json['classe'],
      matricule: json['matricule'],
      email: json['email'],
    );
  }
}

class StudentListPage extends StatefulWidget {
  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List<Student> _students = [];
  String? _selectedClasse;

  final List<String> _classes = ['L1 MAE', 'L2 GEA', 'L3 INFO'];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents({String? classe}) async {
    final uri = classe != null
        ? Uri.parse('http://localhost:3000/api/inscription?classe=\$classe')
        : Uri.parse('http://localhost:3000/api/inscription');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _students = data.map((e) => Student.fromJson(e)).toList();
      });
    } else {
      throw Exception('Erreur lors du chargement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des étudiants'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              value: _selectedClasse,
              hint: Text('Filtrer par classe'),
              items: _classes.map((classe) {
                return DropdownMenuItem(
                  value: classe,
                  child: Text(classe),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClasse = value;
                });
                fetchStudents(classe: value);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 2,
                  child: ListTile(
                    title: Text('${student.prenom} ${student.nom}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Classe : ${student.classe}'),
                        Text('Matricule : ${student.matricule}'),
                        Text('Email : ${student.email}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}