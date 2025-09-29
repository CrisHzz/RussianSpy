import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/widgets/spy_app_bar.dart';
import 'ui/widgets/spy_background.dart';
import 'screens/list_screen.dart';
import 'screens/form_screen.dart';
import 'providers/person_provider.dart';

//inicio de la app
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PersonProvider(),
      child: MaterialApp(
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
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const red = Color(0xFFFF4D4D);

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonProvider>(
      builder: (context, personProvider, child) {
        return Scaffold(
          appBar: SpyAppBar(
            onAllIdentities: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserListScreen()),
            ),
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
                    label: Text(
                      personProvider.isLoading ? "GENERATING..." : "CREATE IDENTITY",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                    onPressed: personProvider.isLoading ? null : () => _generateIdentities(personProvider),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        ),
      );
    },
    );
  }

  Future<void> _generateIdentities(PersonProvider provider) async {
    await provider.generateIdentities();
    
    if (mounted) {
      if (provider.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage),
            backgroundColor: red.withValues(alpha: 0.8),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Generated 5 new identities successfully!'),
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate to list screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserListScreen()),
        );
      }
    }
  }
}
