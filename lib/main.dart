import 'package:flutter/material.dart';
import 'package:keuangan/pages/welcomepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://xiavhchmahxqayetfflc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhpYXZoY2htYWh4cWF5ZXRmZmxjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1MjYwMzEsImV4cCI6MjA2NjEwMjAzMX0.3vJwmCxzWArLBCvO0J8xlV80sl9Fybv7ySjDR_w3beI',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'keuanganku',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Welcomepage(),
    );
  }
}
