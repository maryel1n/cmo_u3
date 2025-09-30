import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/products_provider.dart';
import 'screen/home_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsProvider(), lazy: false),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CMO U3',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4C6FFF),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F1115),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F1115),
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF161A1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          dividerColor: const Color(0xFF2A2F36),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
