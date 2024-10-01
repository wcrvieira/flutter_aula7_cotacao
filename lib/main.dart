import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cotação do Dólar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedDate;
  String? cotacao;
  bool isLoading = false;

  // Função para buscar a cotação
  Future<void> fetchCotacao(String date) async {
    setState(() {
      isLoading = true;
      cotacao = null;
    });

    String apiUrl =
        'https://economia.awesomeapi.com.br/json/daily/USD-BRL/?start_date=$date&end_date=$date';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            cotacao = data[0]['bid'];
          });
        } else {
          setState(() {
            cotacao = 'Cotação não disponível para esta data';
          });
        }
      } else {
        setState(() {
          cotacao = 'Erro ao buscar cotação';
        });
      }
    } catch (error) {
      setState(() {
        cotacao = 'Erro ao buscar cotação';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para selecionar uma data
  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('yyyyMMdd').format(pickedDate);
      });

      fetchCotacao(selectedDate!);
    }
  }

  @override
  void initState() {
    super.initState();
    final todayDate = DateFormat('yyyyMMdd').format(DateTime.now());
    fetchCotacao(todayDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotação do Dólar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => selectDate(context),
              child: const Text('Escolher Data'),
            ),
            const SizedBox(height: 16),
            if (selectedDate != null)
              Text(
                'Data selecionada: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(selectedDate!))}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            if (isLoading)
              const CircularProgressIndicator()
            else if (cotacao != null)
              Text(
                'Cotação do dia (${DateFormat('dd/MM/yyyy').format(DateTime.now())}): \nR\$ $cotacao',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
            else
              const Text('Selecione uma data para ver a cotação'),
          ],
        ),
      ),
    );
  }
}
