import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_app/quiz.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url:
        'https://exofgmkbqgqrdpgfipjj.supabase.co', 
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4b2ZnbWticWdxcmRwZ2ZpcGpqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxMDA1MTEsImV4cCI6MjA3MzY3NjUxMX0.SMoKwWRTWenAaOAc1xdwXhS6FeQghYYRbWTMXMAmF-0', // ضع المفتاح هنا
  );
  runApp(const Quiz());
}
