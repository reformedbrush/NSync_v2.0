import 'package:flutter/material.dart';
import 'package:nsync_stud/screen/homepg.dart';
import 'package:nsync_stud/screen/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  runApp(const MainApp());
  await Supabase.initialize(
    url: 'https://gxomwkpwoxmhdtdsxjph.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd4b213a3B3b3htaGR0ZHN4anBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQzNDU5ODAsImV4cCI6MjA0OTkyMTk4MH0.AksgXgzqkpAGnGxsypvcaotmPeFSdytlAalMljjdLdw',
  );

  runApp(const MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    final session = supabase.auth.currentSession;

    // Navigate to the appropriate screen based on the authentication state
    if (session != null) {
      return StudentHome(); // Replace with your home screen widget
    } else {
      return Login1(); // Replace with your auth page widget
    }
  }
}
