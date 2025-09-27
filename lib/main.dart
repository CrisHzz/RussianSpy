import 'package:flutter/material.dart';
import 'ui/widgets/spy_app_bar.dart';
import 'ui/widgets/spy_background.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RUSSIAN SPY',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF0D1117),
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const red = Color(0xFFFF4D4D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SpyAppBar(
        onAllIdentities: () => debugPrint('All identities pressed'),
      ),
      body: SpyBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // ==== Título ====
                const Text(
                  'Help your Nation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: red,
                    letterSpacing: 4,
                    fontFamily: 'monospace',
                    shadows: [
                      Shadow(offset: Offset(0, 2), blurRadius: 10, color: red),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'IDENTITY SPY DASHBOARD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[400],
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 24),

                // Utilizamos la bandera de Rusia
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: red.withValues(alpha: 0.35),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/en/thumb/f/f3/Flag_of_Russia.svg/1200px-Flag_of_Russia.svg.png',
                    width: 160,
                    height: 106,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 40),

                // Boton home
                Container(
                  width: 280,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: red.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: red.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: red.withValues(alpha: 0.12),
                      foregroundColor: red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add_moderator, size: 20),
                    label: const Text(
                      "CREATE IDENTITY",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                    onPressed: () => debugPrint("Create identity pressed"),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
