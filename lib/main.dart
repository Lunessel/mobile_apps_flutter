import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Flutter Lab 1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _inputController = TextEditingController();
  int _counter = 0;
  String _status = 'Введіть число або Avada Kedavra';

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _status = 'Інкремент: +1';
    });
  }

  void _applyInput() {
    final text = _inputController.text.trim();

    setState(() {
      if (text == 'Avada Kedavra') {
        _counter = 0;
        _status = 'Лічильник скинуто до 0';
        return;
      }

      final parsedValue = int.tryParse(text);
      if (parsedValue == null) {
        _status = 'Помилка: введіть ціле число';
        return;
      }

      _counter += parsedValue;
      _status = 'Додано $parsedValue до лічильника';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('IoT Flutter Lab 1'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Лічильник: $_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Введіть число або Avada Kedavra',
              ),
              onSubmitted: (_) => _applyInput(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _applyInput,
              child: const Text('Застосувати ввід'),
            ),
            const SizedBox(height: 12),
            Text(_status),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
