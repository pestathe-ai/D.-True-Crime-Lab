import 'dart:async';

import 'package:flutter/material.dart';

import '../services/game.dart';
import '../story/model.dart';
import 'cards.dart';
import 'theme.dart';

/// Il telefono di Marta: cronologia, messaggi, posta, galleria, rubrica.
class Home extends StatefulWidget {
  const Home({super.key, required this.game});

  final Game game;

  @override
  State<Home> createState() => _HomeState();
}

class _Tab {
  const _Tab(this.label, this.icon, this.filter);

  final String label;
  final IconData icon;
  final bool Function(Drop d) filter;
}

final _tabs = <_Tab>[
  _Tab('Cronologia', Icons.history, (d) => true),
  _Tab(
    'Messaggi',
    Icons.chat_bubble_outline,
    (d) =>
        d.kind == DropKind.messaggio ||
        d.kind == DropKind.scelta ||
        d.kind == DropKind.vocale,
  ),
  _Tab('Posta', Icons.mail_outline, (d) => d.kind == DropKind.email),
  _Tab('Galleria', Icons.photo_library_outlined, (d) => d.kind == DropKind.foto),
  _Tab('Rubrica', Icons.contacts_outlined, (d) => d.kind == DropKind.contatto),
];

class _HomeState extends State<Home> with WidgetsBindingObserver {
  int _index = 0;
  Timer? _timer;

  /// Contenuti appena visti in questa scheda: restano "NUOVO" finché
  /// non si cambia scheda.
  final Set<String> _fresh = {};

  Game get game => widget.game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => game.tick());
    WidgetsBinding.instance.addPostFrameCallback((_) => _markCurrent());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) game.tick();
    if (state == AppLifecycleState.paused) game.voice.stop();
  }

  void _markCurrent() {
    if (!mounted) return;
    final f = _tabs[_index].filter;
    final ids = game.visible.where(f).where(game.isNew).map((d) => d.id);
    if (ids.isEmpty) return;
    _fresh.addAll(ids);
    game.markSeen(ids.toList());
  }

  @override
  Widget build(BuildContext context) {
    final visible = game.visible;
    final ending = game.ending;
    final status = game.paused
        ? 'In pausa'
        : ending != null
            ? 'Storia conclusa'
            : game.day == 0
                ? 'In attesa'
                : 'Giorno ${game.day} di 7';
    // Segna come visti i contenuti della scheda aperta (dopo il disegno).
    WidgetsBinding.instance.addPostFrameCallback((_) => _markCurrent());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Telefono di Marta V.', style: sora(17, weight: 700)),
            Text(
              '◆ $status',
              style: const TextStyle(fontSize: 12, color: Pal.accent),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Impostazioni',
            onPressed: () => _settings(context),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: _index == 4
          ? _Contacts(game: game, items: visible.where(_tabs[4].filter).toList())
          : _Feed(
              game: game,
              items: visible.where(_tabs[_index].filter).toList(),
              empty: _emptyText(_index),
              fresh: _fresh,
              showSignature: _index == 0,
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() {
            _fresh.clear();
            _index = i;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) => _markCurrent());
        },
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: _badge(
                visible.where(t.filter).where(game.isNew).length,
                Icon(t.icon),
              ),
              label: t.label,
            ),
        ],
      ),
    );
  }

  Widget _badge(int n, Widget child) {
    if (n == 0) return child;
    return Badge(
      label: Text('$n'),
      backgroundColor: Pal.accent,
      textColor: Pal.inkDark,
      child: child,
    );
  }

  String _emptyText(int i) {
    switch (i) {
      case 1:
        return 'Ancora nessun messaggio.\nNessuno sa che hai questo telefono. Per ora.';
      case 2:
        return 'La posta è vuota.';
      case 3:
        return 'Nessuna foto.';
      default:
        return 'Niente di nuovo.';
    }
  }

  void _settings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Pal.surface,
      showDragHandle: true,
      builder: (ctx) => ListenableBuilder(
        listenable: game,
        builder: (ctx, _) {
          final s = game.state;
          if (s == null) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Impostazioni', style: sora(18, weight: 700)),
                  const SizedBox(height: 8),
                  Text(
                    s.clock.preview
                        ? 'Modalità: anteprima veloce (3 minuti al giorno)'
                        : 'Modalità: tempo reale',
                    style: const TextStyle(color: Pal.muted),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notti tranquille'),
                    subtitle: const Text(
                      'Notifiche tra le 23 e le 8 spostate al mattino',
                      style: TextStyle(color: Pal.muted),
                    ),
                    value: s.quietNights,
                    onChanged: game.setQuietNights,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      game.paused ? Icons.play_arrow : Icons.pause,
                      color: Pal.accent,
                    ),
                    title: Text(
                      game.paused ? 'Riprendi la storia' : 'Metti in pausa',
                    ),
                    subtitle: const Text(
                      'In pausa il tempo della storia si ferma',
                      style: TextStyle(color: Pal.muted),
                    ),
                    onTap: game.togglePause,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restart_alt, color: Pal.accent),
                    title: const Text('Ricomincia da capo'),
                    subtitle: const Text(
                      'Cancella le scelte e torna alla schermata iniziale',
                      style: TextStyle(color: Pal.muted),
                    ),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: ctx,
                        builder: (d) => AlertDialog(
                          backgroundColor: Pal.surface2,
                          title: const Text('Ricominciare?'),
                          content: const Text(
                            'Perderai le scelte fatte finora.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(d, false),
                              child: const Text('Annulla'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(d, true),
                              child: const Text('Ricomincia'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true && ctx.mounted) {
                        Navigator.pop(ctx);
                        await game.reset();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Feed extends StatelessWidget {
  const _Feed({
    required this.game,
    required this.items,
    required this.empty,
    required this.showSignature,
    required this.fresh,
  });

  final Game game;
  final List<Drop> items;
  final String empty;
  final bool showSignature;
  final Set<String> fresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            empty,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Pal.muted, height: 1.5),
          ),
        ),
      );
    }
    // I più recenti in alto, come in un vero telefono.
    final list = items.reversed.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: list.length + (showSignature ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == list.length) return const DomSignature();
        return DropCard(
          key: ValueKey(list[i].id),
          drop: list[i],
          game: game,
          highlight: fresh.contains(list[i].id),
        );
      },
    );
  }
}

class _Contacts extends StatelessWidget {
  const _Contacts({required this.game, required this.items});

  final Game game;
  final List<Drop> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final c in items)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: c.callable ? Pal.accent : Pal.surface2,
              foregroundColor: c.callable ? Pal.inkDark : Pal.text,
              child: Text((c.title ?? '?').substring(0, 1)),
            ),
            title: Text(c.title ?? ''),
            subtitle: Text(c.body, style: const TextStyle(color: Pal.muted)),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Pal.accent),
              onPressed: () => _call(context, c),
            ),
          ),
        const DomSignature(),
      ],
    );
  }

  Future<void> _call(BuildContext context, Drop c) async {
    if (!c.callable) {
      final msg = switch (c.id) {
        'c_paolo' => 'Squilla a vuoto. Poi la segreteria: «Paolo Venier, '
            'Ufficio Tecnico. Lasciate un messaggio.»',
        'c_ettore' => 'Squilla a lungo. Nessuno risponde.',
        _ => 'L\'ufficio è chiuso.',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    final storyOver = game.ending != null;
    if (!storyOver) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
          backgroundColor: Pal.surface2,
          title: const Text('Chiamare Casa?'),
          content: const Text(
            'Qualcuno ti ha chiesto di non farlo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Lascia stare'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Chiama'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    final r = await game.callCasa();
    if (r.speaks) {
      game.voice.play('call', r.text.replaceAll('\n', ' '), 'elsa');
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: Pal.surface2,
        icon: const Icon(Icons.phone_in_talk, color: Pal.accent),
        title: const Text('Casa'),
        content: Text(r.text, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () {
              game.voice.stop();
              Navigator.pop(d);
            },
            child: const Text('Riaggancia'),
          ),
        ],
      ),
    );
  }
}
