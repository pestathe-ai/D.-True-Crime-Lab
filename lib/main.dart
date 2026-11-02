import 'package:flutter/material.dart';

import 'services/game.dart';
import 'ui/home.dart';
import 'ui/onboarding.dart';
import 'ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final game = Game();
  runApp(TrueCrimeLabApp(game: game));
  game.load();
}

class TrueCrimeLabApp extends StatelessWidget {
  const TrueCrimeLabApp({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D. True Crime Lab',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: ListenableBuilder(
        listenable: game,
        builder: (context, _) {
          if (!game.loaded) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Pal.accent),
              ),
            );
          }
          if (game.state == null) return Onboarding(game: game);
          return Home(game: game);
        },
      ),
    );
  }
}
